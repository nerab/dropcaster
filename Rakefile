# encoding: utf-8

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
end

task :default => :test

namespace :web do
  file 'website/index.markdown' do |f|
    concat ['website/index.yaml', 'README.markdown'], f
  end

  file 'website/vision.markdown' do |f|
    concat ['website/vision.yaml', 'VISION.markdown'], f
  end

  desc "Generate web page"
  task :generate => ['website/index.markdown', 'website/vision.markdown'] do
    `jekyll build`
  end
end

def concat(sources, destination)
  open(destination, 'a') do |f|
    Array(sources).each do |src|
puts "Appending #{src} to #{f}"
      f << src
    end
  end
end
