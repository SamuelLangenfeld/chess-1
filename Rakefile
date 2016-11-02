begin
  require 'rspec/core/rake_task'

  task :default => :spec

  desc "run tests for chess"
  RSpec::Core::RakeTask.new(:spec) do |task|
    dir = Rake.application.original_dir
    task.pattern = "#{dir}/spec/*_spec.rb"
    task.verbose = false
  end

rescue LoadError
end