# frozen_string_literal: true

$LOAD_PATH.unshift File.dirname(__FILE__)

require 'yaml'
require 'active_support/core_ext/date_time/conversions'
require 'active_support/core_ext/object/blank'

require 'dropcaster/errors'
require 'dropcaster/channel'
require 'dropcaster/item'
require 'dropcaster/channel_file_locator'
require 'dropcaster/version'

module Dropcaster
  CHANNEL_YML = 'channel.yml'
end
