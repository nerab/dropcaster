require 'erb'
require 'uri'

module Dropcaster
  class Channel < DelegateClass(Hash)
    include HashKeys

    def initialize(sources, options)
      super(Hash.new)

      # Assert mandatory options
      [:title, :url, :description].each{|attr|
        raise MissingAttributeError.new(attr) if options[attr].blank?
      }
      
      self.merge!(options)
      self.categories = Array.new
      @source_files = Array.new

      if (sources.respond_to?(:each)) # array
        sources.each{|src|
          add_files(src)
        }
      else
        # single file or directory
        add_files(src)
      end

      @index_template = ERB.new(File.new(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'channel.rss.erb')), 0, "%<>")
    end

    def to_rss
      @index_template.result(binding)
    end

    def items
      all_items = Array.new
      @source_files.each{|src|
        item = Item.new(src)

        # set author and image_url from channel if empty
        item.tag.artist = self.author if item.artist.blank?
        item.image_url = self.image_url if item.image_url.blank?
        
        # Construct absolute URL, based on the channel's enclosure_base attribute
        item.url = enclosure_base || ''
        item.url << '/' unless item.url =~ /\/$/
        item.url += URI.escape(item.file_name, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
        
        all_items << item
      }
      
      all_items.sort{|x, y| y.pub_date <=> x.pub_date}
    end

  private
    def add_files(src)
      if File.directory?(src)
        @source_files.concat(Dir.glob(File.join(src, '*.mp3')))
      else
        @source_files << src
      end
    end
  end
end
