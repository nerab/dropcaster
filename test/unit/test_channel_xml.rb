# frozen_string_literal: true

require 'helper'
require 'xml/libxml'
require 'pry'

class TestChannelXML < MiniTest::Test
  include DropcasterTest

  def setup
    @options = YAML.load_file(File.join(FIXTURES_DIR, Dropcaster::CHANNEL_YML))
    @channel = channel_node(channel_rss)
  end

  #
  # Returnes the XML node for the channel passed as XML string
  #
  def channel_node(rss)
    XML::Document.string(rss).find('//rss/channel').first
  end

  #
  # Returnes the channel under test as XML string
  #
  # Subclasses may overwrite this method in order to re-use the tests in this class, while
  # constructing the XML string in a different way
  #
  def channel_rss
    Dropcaster::Channel.new(FIXTURES_DIR, @options.dup).to_rss
  end

  def test_itunes_item
    item = @channel.find('item[title = "iTunes Name"]').first
    assert(item)

    assert_equal('iTunes Artist', item.find('itunes:author', NS_ITUNES).first.content)
    assert_equal('iTunes Description (Video Pane)', item.find('itunes:summary', NS_ITUNES).first.content)
    assert_equal('http://www.example.com/podcasts/everything/AllAboutEverything.jpg', item.find('itunes:image', NS_ITUNES).first['href'])

    enclosure = item.find('enclosure').first
    assert(enclosure)
    assert_equal('http://www.example.com/podcasts/everything/test/fixtures/iTunes.mp3', enclosure['url'])
    assert_equal('58119', enclosure['length'])
    assert_equal('audio/mp3', enclosure['type'])

    guid = item.find('guid').first
    assert(guid)
    assert_equal('false', guid['isPermaLink'])
    assert_equal('77bf84447c0f69ce4a33a18b0ae1e030b82010de', guid.content)

    assert_equal(File.mtime(FIXTURE_ITUNES_MP3).rfc2822, item.find('pubDate').first.content)
    assert_equal('3', item.find('itunes:duration', NS_ITUNES).first.content)
  end

  def test_special_ampersand_item
    # in the actual XML, this is "special &amp;.mp3", but it gets interpreted by XML::Document
    # if it was just "special &.mp3", it would be invalid XML and we wouldn't get this far
    item = @channel.find('item[title = "test/fixtures/special &.mp3"]').first
    assert(item)

    enclosure = item.find('enclosure').first
    assert(enclosure)
    assert_equal('http://www.example.com/podcasts/everything/test/fixtures/special%20%26.mp3', enclosure['url'])
  end

  def test_uppercase_extension_item
    item = @channel.find('item[title = "test/fixtures/extension.MP3"]').first
    assert(item)

    enclosure = item.find('enclosure').first
    assert(enclosure)
    assert_equal('http://www.example.com/podcasts/everything/test/fixtures/extension.MP3', enclosure['url'])
  end

  def test_attributes_mandatory
    options = { title: 'Test Channel',
                url: 'http://www.example.com/',
                description: 'A test channel',
                enclosures_url: 'http://www.example.com/foo/bar' }

    channel = channel_node(Dropcaster::Channel.new(FIXTURES_DIR, options).to_rss)
    assert_equal('Test Channel', channel.find('title').first.content)
    assert_equal('http://www.example.com/', channel.find('link').first.content)
    assert_equal('A test channel', channel.find('description').first.content)
  end

  def test_attributes_complete
    assert_equal(@options[:title], @channel.find('title').first.content)
    assert_equal(@options[:url], @channel.find('link').first.content)
    assert_equal(@options[:description], @channel.find('description').first.content)
    assert_equal(@options[:subtitle], @channel.find('itunes:subtitle', NS_ITUNES).first.content)
    assert_equal(@options[:language], @channel.find('language').first.content)
    assert_equal(@options[:copyright], @channel.find('copyright').first.content)
    assert_equal(@options[:author], @channel.find('itunes:author', NS_ITUNES).first.content)

    owner = @channel.find('itunes:owner', NS_ITUNES).first
    assert_equal(@options[:owner][:name], owner.find('itunes:name', NS_ITUNES).first.content)
    assert_equal(@options[:owner][:email], owner.find('itunes:email', NS_ITUNES).first.content)
    assert_equal(URI.join(@options[:url], @options[:image_url]).to_s, @channel.find('itunes:image', NS_ITUNES).first['href'])

    categories = @channel.find('itunes:category', NS_ITUNES)
    refute_nil(categories)
    assert_equal(2, categories.size)
    assert_equal('Technology', categories.first['text'])
    assert_equal('Gadgets', categories.first.find('itunes:category', NS_ITUNES).first['text'])
    assert_equal('TV & Film', categories.last['text'])

    assert_equal(@options[:explicit] ? 'Yes' : 'No', @channel.find('itunes:explicit', NS_ITUNES).first.content)
  end
end
