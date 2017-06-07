# frozen_string_literal: true

require 'helper'
require 'tmpdir'
require 'pry'

class TestChannelLocator < MiniTest::Test
  include DropcasterTest

  def setup
    @temp_dir = Dir.mktmpdir
  end

  def teardown
    FileUtils.remove_entry_secure(@temp_dir)
  end

  def test_single_file
    sources = File.join(@temp_dir, 'single_file.mp3')
    assert_location(sources)
  end

  def test_current_directory
    sources = File.join(@temp_dir, '.')
    assert_location(Pathname.new(sources).cleanpath) # Cleanup path before we compare
  end

  def test_single_directory
    source_dir = File.join(@temp_dir, 'single_dir')
    Dir.mkdir(source_dir)
    expected = File.join(@temp_dir, 'single_dir', Dropcaster::CHANNEL_YML)
    assert_equal(expected, Dropcaster::ChannelFileLocator.locate(source_dir))
  end

  def test_array_of_files_same_dir
    sources = []
    sources << File.join(@temp_dir, 'file1.mp3')
    sources << File.join(@temp_dir, 'file2.mp3')
    sources << File.join(@temp_dir, 'file3.mp3')

    assert_location(sources)
  end

  def test_array_of_files_different_dir
    sources = []
    sources << File.join(@temp_dir, 'foo', 'file1.mp3')
    sources << File.join(@temp_dir, 'bar', 'file1.mp3')
    sources << File.join(@temp_dir, 'baz', 'file1.mp3')

    assert_raises Dropcaster::AmbiguousSourcesError do
      Dropcaster::ChannelFileLocator.locate(sources)
    end
  end

  def test_array_with_one_directory
    assert_location(File.join(@temp_dir, ['single_dir']))
  end

  def test_array_with_more_than_a_single_directory
    Dir.mktmpdir { |tmp_dir1|
      Dir.mktmpdir { |tmp_dir2|
        sources = []
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
    assert_equal(File.join(@temp_dir, Dropcaster::CHANNEL_YML), channel_file)
  end
end
