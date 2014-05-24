require 'mp3info'
require 'digest/sha1'

module Dropcaster
  class Item
    attr_reader :file_name, :tag, :tag2, :duration, :file_size, :uuid, :pub_date, :pub_date, :lyrics
    attr_accessor :artist, :image_url, :url, :keywords

    def initialize(file_path, options = nil)
      Mp3Info.open(file_path){|mp3info|
        @file_name = Pathname.new(File.expand_path(file_path)).relative_path_from(Pathname.new(Dir.pwd)).cleanpath.to_s
        @tag = mp3info.tag
        @tag2 = mp3info.tag2
        @duration = mp3info.length
        if @tag2["ULT"]
          @lyrics = {};
          @tag2["ULT"].split(/\x00/).drop(1).each_slice(2) { |k, v| @lyrics[k] = v }
        end
      }

      @file_size = File.new(@file_name).stat.size
      @uuid = Digest::SHA1.hexdigest(File.read(file_name))

      unless tag2.TDR.blank?
        @pub_date = DateTime.parse(tag2.TDR)
      else
        Dropcaster.logger.info("#{file_path} has no pub date set, using the file's modification time")
        @pub_date = DateTime.parse(File.new(file_name).mtime.to_s)
      end
    end
  end
end
