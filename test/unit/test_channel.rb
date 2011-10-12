require 'helper'

class TestChannel < Test::Unit::TestCase
  include DropcasterTest

  def setup
    @options = YAML.load_file(File.join(FIXTURES_DIR, Dropcaster::CHANNEL_YML))
    @channel = Dropcaster::Channel.new(FIXTURES_DIR, @options)
  end

  def test_item_count
    assert_equal(1, @channel.items.size)
  end

  def test_channel
    assert_equal(@options[:title], @channel.title)
    assert_equal(@options[:url], @channel.url)
    assert_equal(@options[:description], @channel.description)
    assert_equal(@options[:subtitle], @channel.subtitle)
    assert_equal(@options[:language], @channel.language)
    assert_equal(@options[:copyright], @channel.copyright)
    assert_equal(@options[:author], @channel.author)

    owner = @channel.owner
    assert_equal(@options[:owner][:name], owner[:name])
    assert_equal(@options[:owner][:email], owner[:email])

    assert_equal(URI.join(@options[:url], @options[:image_url]).to_s, @channel.image_url)
    # TODO :categories: ['Technology', 'Gadgets']
    assert_equal(@options[:explicit], @channel.explicit)
  end
end
