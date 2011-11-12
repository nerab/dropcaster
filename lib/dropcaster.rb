$:.unshift File.dirname(__FILE__)

require 'bundler/setup'
require 'delegate'
require 'yaml'
require 'active_support/core_ext/date_time/conversions'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/module/attribute_accessors'

require 'logger'
require 'active_support/core_ext/logger'

require 'dropcaster/errors'
require 'dropcaster/log_formatter'
require 'dropcaster/hashkeys'
require 'dropcaster/channel'
require 'dropcaster/item'
require 'dropcaster/channel_file_locator'

module Dropcaster
  VERSION = File.read(File.join(File.dirname(__FILE__), *%w[.. VERSION]))
  CHANNEL_YML = 'channel.yml'
  
  mattr_accessor :logger
  
  unless @@logger
    @@logger = Logger.new(STDERR)
    @@logger.level = Logger::WARN
    @@logger.formatter = LogFormatter.new
  end
end
