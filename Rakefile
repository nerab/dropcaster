# encoding: utf-8

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rake/clean'

Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
end

task :default => :test

namespace :web do
  file 'website/index.markdown' do |f|
    concat 'website/_front_matter/index.yaml', 'README.markdown', f
  end
  CLOBBER << 'website/index.markdown'

  file 'website/vision.markdown' do |f|
    concat 'website/_front_matter/vision.yaml', 'VISION.markdown', f
  end
  CLOBBER << 'website/vision.markdown'

  file 'website/contributing.markdown' do |f|
    concat 'website/_front_matter/contributing.yaml', 'CONTRIBUTING.markdown', f
  end
  CLOBBER << 'website/contributing.markdown'

  desc "Generate web page"
  task :generate => ['website/index.markdown', 'website/vision.markdown', 'website/contributing.markdown'] do
    `jekyll build`
  end
end

def concat(*files)
  File.open(files.pop.to_s, 'a') do |f|
    files.each do |src|
      f << File.read(src)
    end
  end
end
