require 'rubygems'
require 'test/unit'
require 'dropcaster'

$:.unshift File.join(File.dirname(__FILE__), *%w[.. test unit])
$:.unshift File.join(File.dirname(__FILE__), *%w[.. test extensions])

require 'windows'

module DropcasterTest
  FIXTURES_DIR = File.join(File.dirname(__FILE__), 'fixtures')
  FIXTURE_ITUNES_MP3 = File.join(FIXTURES_DIR, 'iTunes.mp3')
  NS_ITUNES = "itunes:http://www.itunes.com/dtds/podcast-1.0.dtd"
end
