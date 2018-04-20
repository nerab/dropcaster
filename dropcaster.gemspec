# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dropcaster/version'

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |spec|
  spec.name          = 'dropcaster'
  spec.version       = Dropcaster::VERSION
  spec.authors       = ['Nicholas E. Rabenau']
  spec.email         = ['nerab@gmx.at']
  spec.summary       = 'Simple Podcast Publishing with Dropbox'
  spec.description   = 'Dropcaster is a podcast feed generator for the command line. It is most simple to use with Dropbox, but works equally well with any other hoster.'
  spec.homepage      = 'https://github.com/nerab/dropcaster'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'bundler'
  spec.add_dependency 'nokogiri', '~> 1.8.2'
  spec.add_dependency 'null-logger'
  spec.add_dependency 'ruby-mp3info'

  spec.add_development_dependency 'github-pages'
  spec.add_development_dependency 'guard-bundler'
  spec.add_development_dependency 'guard-minitest'
  spec.add_development_dependency 'libnotify'
  spec.add_development_dependency 'libxml-ruby'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'octokit'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rb-fsevent'
  spec.add_development_dependency 'rb-inotify'
  spec.add_development_dependency 'rubocop'
end
# rubocop:enable Metrics/BlockLength
