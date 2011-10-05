require 'rubygems'
require 'test/unit'
require 'dropcaster'

$:.unshift File.join(File.dirname(__FILE__), *%w[.. test unit])

module DropcasterTest
  FIXTURES_DIR = File.join(File.dirname(__FILE__), 'fixtures')
  NS_ITUNES = "itunes:http://www.itunes.com/dtds/podcast-1.0.dtd"
end
