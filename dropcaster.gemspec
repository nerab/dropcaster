# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dropcaster/version'

Gem::Specification.new do |spec|
  spec.name          = "dropcaster"
  spec.version       = Dropcaster::VERSION
  spec.authors       = ["Nicholas E. Rabenau"]
  spec.email         = ["nerab@gmx.at"]
  spec.summary       = %q{Simple Podcast Publishing with Dropbox}
  spec.description   = %q{Dropcaster is a podcast feed generator for the command line. It is most simple to use with Dropbox, but works equally well with any other hoster.}
  spec.homepage      = "https://github.com/nerab/dropcaster"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'ruby-mp3info'
  spec.add_dependency 'activesupport'

  spec.add_development_dependency 'bundler', "~> 1.5"
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'libxml-ruby'
  spec.add_development_dependency 'guard-minitest'
  spec.add_development_dependency 'guard-bundler'
  spec.add_development_dependency 'libnotify'
  spec.add_development_dependency 'rb-inotify'
  spec.add_development_dependency 'rb-fsevent'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-nav'
  spec.add_development_dependency 'pry-stack_explorer'
  spec.add_development_dependency 'rb-readline'
end
