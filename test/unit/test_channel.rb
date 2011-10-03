require 'helper'
require 'xml/libxml'

class TestChannel < Test::Unit::TestCase
  FIXTURES_DIR = File.join(File.dirname(__FILE__), '..', 'fixtures')
  NS_ITUNES = "itunes:http://www.itunes.com/dtds/podcast-1.0.dtd"
  
  def setup
    @channel = Dropcaster::Channel.new(FIXTURES_DIR, {:title => 'Test Channel', :url => 'http://www.example.com/podcast.rss', :description => 'A test channel'})
  end
  
  def test_items
    assert_equal(1, @channel.items.size)
    assert_equal('77bf84447c0f69ce4a33a18b0ae1e030b82010de', @channel.items.first.uuid)
  end
  
  def test_attributes_mandatory
    channel = XML::Document.string(@channel.to_rss).find("//rss/channel").first
    assert_equal('Test Channel', channel.find('title').first.content)
    assert_equal('http://www.example.com/podcast.rss', channel.find('link').first.content)
    assert_equal('A test channel', channel.find('description').first.content)
  end
  
  def test_attributes_complete
    options = YAML.load_file(File.join(FIXTURES_DIR, 'test_channel.yml'))
    channel = XML::Document.string(Dropcaster::Channel.new(FIXTURES_DIR, options).to_rss).find("//rss/channel").first
    assert_equal(options[:title], channel.find('title').first.content)
    assert_equal(options[:url], channel.find('link').first.content)
    assert_equal(options[:description], channel.find('description').first.content)
    assert_equal(options[:subtitle], channel.find('itunes:subtitle', NS_ITUNES).first.content)
    assert_equal(options[:language], channel.find('language').first.content)
    assert_equal(options[:copyright], channel.find('copyright').first.content)
    assert_equal(options[:author], channel.find('itunes:author', NS_ITUNES).first.content)
    
    owner = channel.find('itunes:owner', NS_ITUNES).first
    assert_equal(options[:owner][:name], owner.find('itunes:name', NS_ITUNES).first.content)
    assert_equal(options[:owner][:email], owner.find('itunes:email', NS_ITUNES).first.content)
    
    assert_equal(options[:image_url], channel.find('itunes:image', NS_ITUNES).first['href'])
    # TODO :categories: ['Technology', 'Gadgets']
    assert_equal(options[:explicit], channel.find('itunes:explicit', NS_ITUNES).first.content)
  end
end
