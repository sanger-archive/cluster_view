# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

begin
  gem 'ci_reporter'
  require 'ci/reporter/rake/rspec'
  require 'ci/reporter/rake/cucumber'
rescue Gem::LoadError => exception
  # Ignore this, you simply don't have the file!
end
