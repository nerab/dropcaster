require 'erb'
require 'uri'

module Dropcaster
  #
  # Represents a podcast feed in the RSS 2.0 format
  #
  class Channel < DelegateClass(Hash)
    include ERB::Util # for h() in the ERB template
    include HashKeys

    STORAGE_UNITS = %w(Byte KB MB GB TB)
    MAX_KEYWORD_COUNT = 12

    # Instantiate a new Channel object. +sources+ must be present and can be a String or Array
    # of Strings, pointing to a one or more directories or MP3 files.
    #
    # +attributes+ is a hash with all attributes for the channel. The following attributes are
    # mandatory when a new channel is created:
    #
    # * <tt>:title</tt> - Title (name) of the podcast
    # * <tt>:url</tt> - URL to the podcast
    # * <tt>:description</tt> - Short description of the podcast (a few words)
    #
    def initialize(sources, attributes)
      super(Hash.new)

      # Assert mandatory attributes
      [:title, :url, :description].each{|attr|
        raise MissingAttributeError.new(attr) if attributes[attr].blank?
      }

      self.merge!(attributes)
      self.explicit = yes_no_or_input(attributes[:explicit])
      @source_files = Array.new

      # if (sources.respond_to?(:each)) # array
      if sources.is_a? Array
        sources.each do |src|
          add_files(src)
        end
      else
        # single file or directory
        add_files(sources)
      end

      # If not absolute, prepend the image URL with the channel's base to make an absolute URL
      unless self.image_url.blank? || self.image_url =~ /^https?:/
        Dropcaster.logger.info("Channel image URL '#{self.image_url}' is relative, so we prepend it with the channel URL '#{self.url}'")
        self.image_url = (URI.parse(self.url) + self.image_url).to_s
      end

      # If enclosures_url is not given, take the channel URL as a base.
      if self.enclosures_url.blank?
        Dropcaster.logger.info("No enclosure URL given, using the channel's enclosure URL")
        self.enclosures_url = self.url
      end

      # Warn if keyword count is larger than recommended
      assert_keyword_count(self.keywords)

      channel_template = self.channel_template || File.join(File.dirname(__FILE__), '..', '..', 'templates', 'channel.rss.erb')

      begin
        @erb_template = ERB.new(IO.read(channel_template), 0, "%<>")
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

        Dropcaster.logger.debug("Adding new item from file #{src}")

        # set author and image_url from channel if empty
        if item.artist.blank?
          Dropcaster.logger.info("#{src} has no artist, using the channel's author")
          item.tag.artist = self.author
        end

        if item.image_url.blank?
          Dropcaster.logger.info("#{src} has no image URL set, using the channel's image URL")
          item.image_url = self.image_url
        end

        # construct absolute URL, based on the channel's enclosures_url attribute
        item.url = (URI.parse(enclosures_url) + item.file_name)

        # Warn if keyword count is larger than recommended
        assert_keyword_count(item.keywords)

        all_items << item
      }

      all_items.sort{|x, y| y.pub_date <=> x.pub_date}
    end

    # from http://stackoverflow.com/questions/4136248
    def humanize_time(secs)
      [[60, :s], [60, :m], [24, :h], [1000, :d]].map{ |count, name|
        if secs > 0
          secs, n = secs.divmod(count)
          "#{n.to_i}#{name}"
        end
      }.compact.reverse.join(' ')
    end

    # Fixed version of https://gist.github.com/260184
    def humanize_size(number)
      return nil if number.nil?

      storage_units_format = '%n %u'

      if number.to_i < 1024
        unit = number > 1 ? 'Bytes' : 'Byte'
        return storage_units_format.gsub(/%n/, number.to_i.to_s).gsub(/%u/, unit)
      else
        max_exp  = STORAGE_UNITS.size - 1
        number   = Float(number)
        exponent = (Math.log(number) / Math.log(1024)).to_i # Convert to base 1024
        exponent = max_exp if exponent > max_exp # we need this to avoid overflow for the highest unit
        number  /= 1024 ** exponent

        unit = STORAGE_UNITS[exponent]
        return storage_units_format.gsub(/%n/, number.to_i.to_s).gsub(/%u/, unit)
      end
    end

  private
    def add_files(src)
      if File.directory?(src)
        @source_files.concat(Dir.glob(File.join(src, '*.mp3')))
      else
        @source_files << src
      end
    end

    #
    # Deal with Ruby's autoboxing of Yes, No, true, etc values in YAML
    #
    def yes_no_or_input(flag)
      case flag
        when nil
          nil
        when true
          'Yes'
        when false
          'No'
      else
        flag
      end
    end

    #
    # http://snippets.dzone.com/posts/show/4578
    #
    def truncate(string, count = 30)
    	if string.length >= count
    		shortened = string[0, count]
    		splitted = shortened.split(/\s/)
    		words = splitted.length
    		splitted[0, words - 1].join(' ') + '...'
    	else
    		string
    	end
    end

    def assert_keyword_count(keywords)
      Dropcaster.logger.info("The list of keywords has #{keywords.size} entries, which exceeds the recommended maximum of #{MAX_KEYWORD_COUNT}.") if keywords && MAX_KEYWORD_COUNT < keywords.size
    end
  end
end
