require "bundler/gem_tasks"
require "rake/extensiontask"
require "rspec/core/rake_task"

Rake::ExtensionTask.new "objspace_helpers" do |ext|
  ext.lib_dir = "lib/objspace_helpers"
end

RSpec::Core::RakeTask.new

task spec: :compile

task default: :spec
task test: :spec

task :clean do
  FileUtils.rm_rf File.join(File.dirname(__FILE__), "tmp/")
  FileUtils.rm_f Dir.glob(File.join(File.dirname(__FILE__), "ext/objspace_helpers/*.o"))
  FileUtils.rm_f File.join(File.dirname(__FILE__), "lib/objspace_helpers/objspace_helpers.bundle")
end
