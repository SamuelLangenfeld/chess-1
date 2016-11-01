begin
  require 'rspec/core/rake_task'

  task :default => :spec

  desc "run tests for chess"
  RSpec::Core::RakeTask.new(:spec) do |task|
    task.verbose = false
  end

rescue LoadError
end