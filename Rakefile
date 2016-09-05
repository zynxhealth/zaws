require 'rubygems'
require 'bundler'
require "bundler/gem_tasks"
require 'cucumber'
require 'cucumber/rake/task'
require 'coveralls/rake/task'
Bundler.setup
Bundler::GemHelper.install_tasks

Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = "feature --format pretty"
end 

require 'rspec/core/rake_task'
desc "Run RSpec"
RSpec::Core::RakeTask.new do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = ['--color', '--format documentation']
end

Coveralls::RakeTask.new

desc "Run tests, both RSpec and Cucumber, then push coverage to Coveralls."
task :test => [:spec, :cucumber, 'coveralls:push']

task :default => :test
