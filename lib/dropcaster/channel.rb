# frozen_string_literal: true

require 'erb'
require 'uri'
require 'dropcaster/logging'

module Dropcaster
  #
  # Represents a podcast feed in the RSS 2.0 format
  #
  class Channel
    include Logging
    include ERB::Util # for h() in the ERB template

    STORAGE_UNITS = %w[Byte KB MB GB TB].freeze
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
      # Assert mandatory attributes
      %i[title url description].each { |attr|
        raise MissingAttributeError.new(attr) if attributes[attr].blank?
      }

      @attributes = attributes
      @attributes[:explicit] = yes_no_or_input(attributes[:explicit])
      @source_files = []

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
      unless @attributes[:image_url].blank? || @attributes[:image_url] =~ /^https?:/
        logger.info("Channel image URL '#{@attributes[:image_url]}' is relative, so we prepend it with the channel URL '#{@attributes[:url]}'")
        @attributes[:image_url] = (URI.parse(@attributes[:url]) + @attributes[:image_url]).to_s
      end

      # If enclosures_url is not given, take the channel URL as a base.
      if @attributes[:enclosures_url].blank?
        logger.info("No enclosure URL given, using the channel's enclosure URL")
        @attributes[:enclosures_url] = @attributes[:url]
      end

      # Warn if keyword count is larger than recommended
      assert_keyword_count(@attributes[:keywords])

      channel_template = @attributes[:channel_template] || File.join(File.dirname(__FILE__), '..', '..', 'templates', 'channel.rss.erb')

      begin
        @erb_template = ERB.new(IO.read(channel_template), 0, '%<>')
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
      all_items = []
      @source_files.each { |src|
        item = Item.new(src)

        logger.debug("Adding new item from file #{src}")

        # set author and image_url from channel if empty
        if item.tag.artist.blank?
          logger.info("#{src} has no artist, using the channel's author")
          item.tag.artist = @attributes[:author]
        end

        if item.image_url.blank?
          logger.info("#{src} has no image URL set, using the channel's image URL")
          item.image_url = @attributes[:image_url]
        end

        # construct absolute URL, based on the channel's enclosures_url attribute
        item.url = URI.parse(enclosures_url) + item.file_path.each_filename.map { |p| url_encode(p) }.join('/')

        # Warn if keyword count is larger than recommended
        assert_keyword_count(item.keywords)

        all_items << item
      }

      all_items.sort { |x, y| y.pub_date <=> x.pub_date }
    end

    # from http://stackoverflow.com/questions/4136248
    def humanize_time(secs)
      [[60, :s], [60, :m], [24, :h], [1000, :d]].map { |count, name|
        if secs.positive?
          secs, n = secs.divmod(count)
          "#{n.to_i}#{name}"
        end
      }.compact.reverse.join(' ')
    end

    # Fixed version of https://gist.github.com/260184
    def humanize_size(number)
      return nil if number.nil?

      if number.to_i < 1024
        unit = number > 1 ? 'Bytes' : 'Byte'
      else
        max_exp  = STORAGE_UNITS.size - 1
        number   = Float(number)
        exponent = (Math.log(number) / Math.log(1024)).to_i # Convert to base 1024
        exponent = max_exp if exponent > max_exp # we need this to avoid overflow for the highest unit
        number  /= 1024**exponent
        unit = STORAGE_UNITS[exponent]
      end

      '%n %u'.gsub(/%n/, number.to_i.to_s).gsub(/%u/, unit)
    end

    #
    # Delegate all unknown methods to @attributes
    #
    # rubocop:disable Style/MethodMissing
    def method_missing(meth, *args)
      m = meth.id2name
      if /=$/.match?(m)
        @attributes[m.chop.to_sym] = (args.length < 2 ? args[0] : args)
      else
        @attributes[m.to_sym]
      end
    end
    # rubocop:enable Style/MethodMissing

    def respond_to_missing?(meth, *)
      /=$/.match?(meth.id2name) || super
    end

    private

    def add_files(src)
      if File.directory?(src)
        @source_files.concat(Dir.glob(File.join(src, '*.mp3'), File::FNM_CASEFOLD))
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
    def truncate(string, count=30)
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
      if keywords && MAX_KEYWORD_COUNT < keywords.size
        logger.info("The list of keywords has #{keywords.size} entries, which exceeds the recommended maximum of #{MAX_KEYWORD_COUNT}.")
      end
    end
  end
end
