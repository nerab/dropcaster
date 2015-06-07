# encoding: utf-8

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
end

task :default => :test

namespace :web do
  directory '_site'

  file '_site/index.html' => '_site' do |f|
    `pandoc -o #{f} README.markdown`
  end

  desc "Generate web page"
  task :generate => ['_site/index.html']
end
