# frozen_string_literal: true

require 'logger'

module Dropcaster
  module Logging
    attr_writer :logger

    def logger
      @logger ||= NullLogger.new
    end
  end

  class LogFormatter < Logger::Formatter
    def call(severity, time, program_name, message)
      "#{severity}: #{message}\n"
    end
  end
end
