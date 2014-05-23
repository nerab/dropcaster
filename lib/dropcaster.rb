$:.unshift File.dirname(__FILE__)

require 'bundler/setup'
require 'yaml'
require 'active_support/core_ext/date_time/conversions'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/module/attribute_accessors'

require 'logger'

require 'dropcaster/errors'
require 'dropcaster/log_formatter'
require 'dropcaster/channel'
require 'dropcaster/item'
require 'dropcaster/channel_file_locator'
require 'dropcaster/version'

module Dropcaster
  CHANNEL_YML = 'channel.yml'

  mattr_accessor :logger

  unless @@logger
    @@logger = Logger.new(STDERR)
    @@logger.level = Logger::WARN
    @@logger.formatter = LogFormatter.new
  end
end
