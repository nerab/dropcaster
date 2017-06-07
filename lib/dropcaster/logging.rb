# frozen_string_literal: true

require 'null_logger'

module Dropcaster
  module Logging
    attr_writer :logger

    def logger
      @logger ||= NullLogger.new
    end
  end
end
