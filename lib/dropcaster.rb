$:.unshift File.dirname(__FILE__)

require 'bundler/setup'
require 'delegate'
require 'yaml'
require 'active_support/core_ext/date_time/conversions'
require 'active_support/core_ext/object/blank'

require 'dropcaster/errors'
require 'dropcaster/hashkeys'
require 'dropcaster/channel'
require 'dropcaster/item'

module Dropcaster
  VERSION = '0.0.1'
end
