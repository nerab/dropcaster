# frozen_string_literal: true

require 'helper'

class TestChannel < MiniTest::Test
  include DropcasterTest

  def setup
    @options = YAML.load_file(File.join(FIXTURES_DIR, Dropcaster::CHANNEL_YML))
    @channel = Dropcaster::Channel.new(FIXTURES_DIR, @options)
  end

  def test_item_count
    assert_equal(NUMBER_OF_MP3_FILES, @channel.items.size)
  end

  def test_channel
    assert_equal(@options[:title], @channel.title)
    assert_equal(@options[:url], @channel.url)
    assert_equal(@options[:description], @channel.description)
    assert_equal(@options[:subtitle], @channel.subtitle)
    assert_equal(@options[:language], @channel.language)
    assert_equal(@options[:copyright], @channel.copyright)
    assert_equal(@options[:author], @channel.author)
    assert_equal(@options[:keywords], @channel.keywords)

    owner = @channel.owner
    assert_equal(@options[:owner][:name], owner[:name])
    assert_equal(@options[:owner][:email], owner[:email])

    assert_equal(URI.join(@options[:url], @options[:image_url]).to_s, @channel.image_url)

    categories = @channel.categories
    assert_equal(@options[:categories], categories)
  end

  def test_channel_url_without_slash
    @options[:url] << 'index.html'
    @channel = Dropcaster::Channel.new(FIXTURES_DIR, @options)
    assert_equal(@options[:url], @channel.url)
  end

  def test_channel_explicit_yes
    assert_channel_explicit('Yes', true)
  end

  def test_channel_explicit_no
    assert_channel_explicit('No', false)
  end

  def test_channel_explicit_nil
    @options[:explicit] = nil
    channel = Dropcaster::Channel.new(FIXTURES_DIR, @options)
    assert_nil(channel.explicit)
  end

  def test_channel_explicit_clean
    assert_channel_explicit('Clean', 'Clean')
  end

  def assert_channel_explicit(expected, value)
    @options[:explicit] = value
    channel = Dropcaster::Channel.new(FIXTURES_DIR, @options)
    assert_equal(expected, channel.explicit)
  end

  def test_raise_on_missing_title
    assert_raises Dropcaster::MissingAttributeError do
      Dropcaster::Channel.new(FIXTURES_DIR, { url: 'bar', description: 'foobar' })
    end
  end

  def test_raise_on_missing_url
    assert_raises Dropcaster::MissingAttributeError do
      Dropcaster::Channel.new(FIXTURES_DIR, { title: 'foo', description: 'foobar' })
    end
  end

  def test_raise_on_missing_description
    assert_raises Dropcaster::MissingAttributeError do
      Dropcaster::Channel.new(FIXTURES_DIR, { title: 'foo', url: 'bar' })
    end
  end
end
