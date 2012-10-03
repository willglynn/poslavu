#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ['--color --format documentation --tag ~live']
end

task :default => :spec
task :test => :spec

desc "Run tests against the live POSLavu servers"
task :live do
  sh "bundle exec rspec --tag live --color --format documentation"
end
