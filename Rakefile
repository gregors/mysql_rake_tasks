require 'bundler/gem_helper'
Bundler::GemHelper.install_tasks


task :default => :test

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
  t.warning = false
end
