require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test

namespace :db do
  desc "Build the database from source data"
  task :build do
    ruby "scripts/build_database.rb"
  end

  desc "Verify the database integrity"
  task :verify do
    ruby "scripts/verify_database.rb"
  end
end

task :build => 'db:build'
