require 'erb'
require 'uri'

module Dropcaster
  #
  # Represents a podcast feed in the RSS 2.0 format
  #
  class Channel < DelegateClass(Hash)
    include HashKeys

    # Instantiate a new Channel object. +sources+ must be present and can be a String or Array
    # of Strings, pointing to a one or more directories or MP3 files.
    #
    # +options+ is a hash with all attributes for the channel. The following attributes are
    # mandatory when a new channel is created:
    #
    # * <tt>:title</tt> - Title (name) of the podcast
    # * <tt>:url</tt> - URL to the podcast
    # * <tt>:description</tt> - Short description of the podcast (a few words)
    #
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

      # Prepend the image URL with the channel's base to make an absolute URL
      self.image_url = URI.join(self.url, self.image_url).to_s unless self.image_url.blank? || self.image_url =~ /^https?:/

      channel_template = self.channel_template || File.join(File.dirname(__FILE__), '..', '..', 'templates', 'iTunes.rss.erb')

      begin
        @erb_template = ERB.new(File.new(channel_template), 0, "%<>")
      rescue Errno::ENOENT => e
        raise TemplateNotFoundError.new(e.message)
      end
    end

    #
    # Returns this channel as an RSS representation. The actual rendering is done with the help
    # of an ERB template. By default, it is expected as ../../templates/channel.rss.erb (relative)
    # to channel.rb.
    #
    def to_rss
      @erb_template.result(binding)
    end

    #
    # Returns all items (episodes) of this channel, ordered by newest-first.
    #
    def items
      all_items = Array.new
      @source_files.each{|src|
        item = Item.new(src)

        # set author and image_url from channel if empty
        item.tag.artist = self.author if item.artist.blank?
        item.image_url = self.image_url if item.image_url.blank?

        # construct absolute URL, based on the channel's enclosures_url attribute
        # If enclosures_url is not given, take the channel URL as a base.
        self.enclosures_url = self.url if self.enclosures_url.blank?
        self.enclosures_url << '/' unless self.enclosures_url =~ /\/$/
        item.url = URI.join(URI.escape(self.enclosures_url), URI.escape(item.file_name))

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
