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
      result, leaked_addrs = nil

      # Inventory of objects already existing
      GC.start
      initial_addrs = ObjspaceHelpers.dump_all_addresses

      # Run once with full object tracing
      ObjectSpace::trace_object_allocations do
        result = block.call
        GC.start
        leaked_addrs = ObjspaceHelpers.dump_all_addresses - initial_addrs
      end

      # Now eliminate all objects GCed in subsequent requests
      additional_calls.times.each do
        block.call
        GC.start
        leaked_addrs = leaked_addrs & ObjspaceHelpers.dump_all_addresses
      end

      # Find the actual address info
      obj_infos = ObjspaceHelpers.info_for_address(leaked_addrs)

      report_filename = format('tmp/report_%s.txt', request.uuid)

      File.open(Rails.root.join(report_filename), 'w') do |f|
        f.puts "Report for #{request.path}\n\n"

        references = {}
        obj_infos.each do |addr,i|
          (i['references'] || []).each do |ref|
            references[ref] ||= []
            references[ref] << addr
          end
        end

        obj_infos.each do |addr,i|
          i['referenced_by'] = (references[addr] || []) - [addr]
        end

        f.puts "Rails app"
        f.puts "---------\n"
        rails_addrs = leaked_addrs.select {|i| obj_infos[i]['file'] && obj_infos[i]['file'].starts_with?(Rails.root.to_s) }
        output_leaks(f, rails_addrs, obj_infos)

        f.puts "Gems"
        f.puts "----\n"
        output_leaks(f, leaked_addrs - rails_addrs, obj_infos)
      end

      Rails.logger.info "Memory leak statistics saved to #{report_filename}"

      result
    end

    # Inspired by http://blog.skylight.io/hunting-for-leaks-in-ruby/
    def output_leaks(f, addresses, obj_infos, depth = 0, parents = [])
      relevant_objs = obj_infos.slice(*addresses).values

      relevant_objs.group_by do |x|
        x.slice('type', 'file', 'line')
      end.map do |group,y|
        [group, y.count, y.sum {|i| i['bytesize'] || 0 }, y.sum {|i| i['memsize'] || 0 }, y.map {|i| i['referenced_by'] }.flatten]
      end.sort do |a,b|
        b[1] <=> a[1]
      end.each do |group,count,bytesize,memsize,referenced_by|
        f.puts " " * depth + "Leaked #{count} #{group['type']} objects of size #{bytesize}/#{memsize} at: #{group['file']}:#{group['line']}"
        unless depth > 2
          parents = parents + addresses
          output_leaks(f, referenced_by - parents, obj_infos, depth + 1, parents + referenced_by)
        end
      end

      if depth == 0
        memsize = relevant_objs.sum {|i| i['memsize'] || 0 }
        bytesize = relevant_objs.sum {|i| i['bytesize'] || 0 }
        f.puts "\nTotal Size: #{bytesize}/#{memsize}\n\n"
      end
    end
  end
end
