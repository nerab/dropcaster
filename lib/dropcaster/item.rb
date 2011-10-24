require 'mp3info'
require 'digest/sha1'

module Dropcaster
  class Item < DelegateClass(Hash)
    include HashKeys

    def initialize(file_path, options = nil)
      super(Hash.new)

      Mp3Info.open(file_path){|mp3info|
        self[:file_name] = Pathname.new(File.expand_path(file_path)).relative_path_from(Pathname.new(Dir.pwd)).cleanpath.to_s
        self[:tag] = mp3info.tag
        self[:tag2] = mp3info.tag2
        self[:duration] = mp3info.length
      }

      self[:file_size] = File.new(self.file_name).stat.size
      self[:uuid] = Digest::SHA1.hexdigest(File.read(self.file_name))

      unless self.tag2.TDR.blank?
        self[:pub_date] = DateTime.parse(self.tag2.TDR)
      else
        Dropcaster.logger.info("#{file_path} has no pub date set, using the file's modification time")
        self[:pub_date] = DateTime.parse(File.new(self.file_name).mtime.to_s)
      end

      # Remove iTunes normalization crap (if configured)
      if options && options[:strip_itunes_private]
        Dropcaster.logger.info("Removing iTunes' private normalization information from comments")
        self.tag2.COM.delete_if{|comment|
          comment =~ /^( [0-9A-F]{8}){10}$/
        }
      end

      # Convert lyrics frame into a hash, keyed by the three-letter language code
      if tag2.ULT
        lyrics_parts = tag2.ULT.split(0.chr)

        if lyrics_parts && 3 == lyrics_parts.size
          self.lyrics = Hash.new
          self.lyrics[lyrics_parts[1]] = lyrics_parts[2]
        end
      end
    end
  end
end
