require 'rubygems'
require 'bundler'
require "bundler/gem_tasks"
require 'cucumber'
require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:feature) do |t|
  t.cucumber_opts = "feature --format pretty"
end 

require 'rspec/core/rake_task'
desc "Run RSpec"
RSpec::Core::RakeTask.new do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = ['--color', '--format documentation']
end

desc "Run tests, both RSpec and Cucumber"
task :test => [:spec, :cucumber]

task :default => :test
