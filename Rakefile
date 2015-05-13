require "rubygems"
require "bundler/setup"
require 'rake/testtask'
require "bundler/gem_tasks"

namespace :test do
  Rake::TestTask.new(:units) do |t|
    t.pattern = "spec/*_spec.rb"
  end
end

desc 'Run tests'
task :test => %w[test:units]

task :default => :test
