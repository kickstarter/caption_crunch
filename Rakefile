require "rubygems"
require "bundler/setup"
require 'rake/testtask'

namespace :test do
  Rake::TestTask.new(:units) do |t|
    t.pattern = "spec/*_spec.rb"
  end
end

desc 'Run tests'
task :test => %w[test:units]

task :default => :test
