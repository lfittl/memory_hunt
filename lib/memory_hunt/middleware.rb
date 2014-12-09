require 'objspace_helpers'

module MemoryHunt
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      context(env)
    end

    def context(env, app = @app)
      request = ActionDispatch::Request.new(env)
      return app.call(env) if skip?(request)

      find_leak(request) do
        app.call(env)
      end
    end

    def skip?(request)
      request.path.starts_with?('/asset')
    end

    private

    def find_leak(request, additional_calls: 1, &block)
      # Run block once to get return value and avoid false positives
      result = block.call
      GC.start
      GC.start

      # Run block again and try to find leaked objects
      top_level_leaks, leaks_by_source = ObjspaceHelpers.find_leak_sources(trace: true, &block)

      report_filename = format('tmp/report_%s.txt', Time.now.to_i)

      File.open(Rails.root.join(report_filename), 'w') do |f|
        f.puts "Report for #{request.path}\n"

        f.puts "\nRails app"
        f.puts "---------\n"
        rails_leaks = leaks_by_source.keys.select {|source| source.info['file'] && source.info['file'].starts_with?(Rails.root.to_s) }
        output_leaks(f, leaks_by_source.slice(rails_leaks))

        f.puts "\nGems"
        f.puts "----\n"
        output_leaks(f, leaks_by_source.except(rails_leaks))

        f.puts "\nTop-level leaks"
        f.puts "---------------\n"
        f.puts format("Not implemented, failed to display %d leaks", top_level_leaks.size)
      end

      Rails.logger.info "Memory leak statistics saved to #{report_filename}"

      result
    end

    # Inspired by http://blog.skylight.io/hunting-for-leaks-in-ruby/
    def output_leaks(f, leaks_by_source)
      leaks_by_source.group_by do |source, leaks|
        info = source.info
        Gem.paths.path.each { |p| info['file'].gsub! %r{^#{p}/}, '' } if info['file']
        info.slice('type', 'file', 'line')
      end.map do |group, y|
        [group, y.count, y.map {|_source, leaks| leaks }.flatten]
      end.sort do |a,b|
        b[1] <=> a[1]
      end.each do |group, count, leaks|
        f.puts "#{count} left-over #{group['type']}s referenced by #{group['file']}:#{group['line']}"

        leaks.group_by do |leak|
          info = leak.info
          Gem.paths.path.each { |p| info['file'].gsub! %r{^#{p}/}, '' } if info['file']
          info.slice('type', 'file', 'line')
        end.map do |group, y|
          [group, y.count, y.map {|leak| leak.info['value'] }.compact]
        end.sort do |a,b|
          b[1] <=> a[1]
        end.each do |group, count, values|
          f.puts "  #{count} #{group['type']} at #{group['file']}:#{group['line']}"
          values.each do |v|
            f.puts format("   value (%d): %s", v.size, v[0..100].inspect)
          end
        end
      end
    end
  end
end
