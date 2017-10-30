# frozen_string_literal: true

require 'mp3info'
require 'digest/sha1'
require 'dropcaster/logging'

module Dropcaster
  class Item
    include Logging

    attr_reader :file_name, :tag, :tag2, :duration, :file_size, :uuid, :pub_date, :lyrics
    attr_accessor :artist, :image_url, :url, :keywords

    def initialize(file_path, options=nil)
      Mp3Info.open(file_path) { |mp3info|
        @file_name = Pathname.new(File.expand_path(file_path)).relative_path_from(Pathname.new(Dir.pwd)).cleanpath.to_s
        @tag = mp3info.tag
        @tag2 = mp3info.tag2
        @duration = mp3info.length
        if @tag2['ULT']
          @lyrics = {}
          @tag2['ULT'].split(/\x00/).drop(1).each_slice(2) { |k, v| @lyrics[k] = v }
        end
      }

      @file_size = File.new(@file_name).stat.size
      @uuid = Digest::SHA1.hexdigest(File.read(file_name))

      if tag2.TDR.blank?
        logger.info("#{file_path} has no pub date set, using the file's modification time")
        @pub_date = Time.parse(File.new(file_name).mtime.to_s)
      else
        @pub_date = Time.parse(tag2.TDR)
      end
    end
  end
end
