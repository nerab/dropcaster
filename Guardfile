# frozen_string_literal: true

guard 'bundler' do
  watch('Gemfile')
  watch(/^.*\.gemspec/)
end

guard 'minitest' do
  watch(%r{^test/unit/test_(.*)\.rb})
  watch(%r{^lib/*\.rb}) { 'test/unit' }
  watch(%r{^lib/.*/*\.rb}) { 'test/unit' }
  watch(%r{^lib/.*/([^/]+)\.rb$}) { |m| "test/unit/test_#{m[1]}.rb" }
  watch(%r{^test/helper\.rb}) { 'test/unit' }
end
