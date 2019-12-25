# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rake/clean'
require 'rubocop/rake_task'
require 'dropcaster'

RuboCop::RakeTask.new

Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
end

task default: %i[rubocop test]

namespace :web do
  file 'website/index.markdown' do |f|
    concat 'website/_front_matter/index.yaml', 'README.markdown', f
  end
  CLOBBER << 'website/index.markdown'

  file 'website/vision.markdown' do |f|
    concat 'website/_front_matter/vision.yaml', 'VISION.markdown', f
  end
  CLOBBER << 'website/vision.markdown'

  file 'website/contributors.markdown' do
    require 'dropcaster/contributors'
    File.write('website/contributors.markdown', Dropcaster.contributors)
  end
  CLOBBER << 'website/contributors.markdown'

  file 'website/contributing.md' => 'website/contributors.markdown' do |f|
    concat 'website/_front_matter/contributing.yaml', 'CONTRIBUTING.md', f
    concat 'website/contributors.markdown', f
  end
  CLOBBER << 'website/contributing.md'

  desc 'Generate web page'
  task generate: ['website/index.markdown', 'website/vision.markdown', 'website/contributing.md'] do
    cd 'website' do
      `bundle exec jekyll build`
    end
  end
end

def concat(*files)
  File.open(files.pop.to_s, 'a') do |f|
    files.each do |src|
      f << File.read(src)
    end
  end
end
