require 'mp3info'
require 'digest/sha1'

module Dropcaster
  class Item < DelegateClass(Hash)
    include HashKeys

    def initialize(file_path, options = nil)
      super(Hash.new)

      Mp3Info.open(file_path){|mp3info|
        self[:file_name] = Pathname.new(file_path).cleanpath.to_s
        self[:tag] = mp3info.tag
        self[:tag2] = mp3info.tag2
        self[:duration] = mp3info.length
      }

      self[:file_size] = File.new(self.file_name).stat.size
      self[:uuid] = Digest::SHA1.hexdigest(File.read(self.file_name))
      
      if self.tag2.TDR.blank?
        self[:pub_date] = DateTime.parse(File.new(self.file_name).mtime.to_s)
      else
        self[:pub_date] = DateTime.parse(self.tag2.TDR)
      end
      
      # Remove iTunes normalization crap (if configured)
      self.tag2.COM.delete_if{|comment|
        comment =~ /^( [0-9A-F]{8}){10}$/
      } if options && options[:strip_itunes_private]
      
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
