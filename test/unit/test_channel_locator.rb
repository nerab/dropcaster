require 'helper'
require 'tmpdir'

class TestChannelLocator < Test::Unit::TestCase
  CHANNEL_YML = 'channel.yml'

  class << self
    attr_reader :temp_dir

    def startup
      @temp_dir = Dir.mktmpdir
    end

    def shutdown
      FileUtils.remove_entry_secure(@temp_dir)
    end

    def suite
      # from http://stackoverflow.com/questions/255969#778701
      _suite = super

      def _suite.run(*args)
        TestChannelLocator.startup()
        super
        TestChannelLocator.shutdown()
      end

      _suite
    end
  end

  def test_single_file
    sources = File.join(TestChannelLocator.temp_dir, 'single_file.mp3')
    assert_location(sources)
  end

  def test_current_directory
    sources = File.join(TestChannelLocator.temp_dir, '.')
    assert_location(sources)
  end

  def test_single_directory
    sources = File.join(TestChannelLocator.temp_dir, 'single_dir')
    assert_location(sources)
  end

  def test_array_of_files_same_dir
    sources = Array.new
    sources << File.join(TestChannelLocator.temp_dir, 'file1.mp3')
    sources << File.join(TestChannelLocator.temp_dir, 'file2.mp3')
    sources << File.join(TestChannelLocator.temp_dir, 'file3.mp3')

    assert_location(sources)
  end

  def test_array_of_files_different_dir
    sources = Array.new
    sources << File.join(TestChannelLocator.temp_dir, 'foo', 'file1.mp3')
    sources << File.join(TestChannelLocator.temp_dir, 'bar', 'file1.mp3')
    sources << File.join(TestChannelLocator.temp_dir, 'baz', 'file1.mp3')

    assert_raises Dropcaster::AmbiguousSourcesError do
      Dropcaster::ChannelFileLocator.locate(sources)
    end
  end

  def test_array_with_one_directory
    assert_location(File.join(TestChannelLocator.temp_dir, ['single_dir']))
  end

  def test_array_with_more_than_a_single_directory
    Dir.mktmpdir{|tmp_dir1|
      Dir.mktmpdir{|tmp_dir2|
        sources = Array.new
        sources << File.join(tmp_dir1, 'another_dir')
        sources << File.join(tmp_dir2, 'another_dir')

        assert_raises Dropcaster::AmbiguousSourcesError do
          Dropcaster::ChannelFileLocator.locate(sources)
        end
      }
    }
  end

  private

  def assert_location(sources)
    channel_file = Dropcaster::ChannelFileLocator.locate(sources)
    assert_equal(File.join(TestChannelLocator.temp_dir, CHANNEL_YML), channel_file)
  end
end
