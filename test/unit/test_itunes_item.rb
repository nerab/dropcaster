# frozen_string_literal: true

require 'helper'

class TestItunesItem < MiniTest::Test
  include DropcasterTest

  def setup
    @item = Dropcaster::Item.new(FIXTURE_ITUNES_MP3)
  end

  def test_basics
    assert_in_delta(3, @item.duration, 0.05)
    assert_equal(58119, @item.file_size)
    assert_equal('77bf84447c0f69ce4a33a18b0ae1e030b82010de', @item.uuid)
    assert_equal(File.mtime(FIXTURE_ITUNES_MP3).to_i, @item.pub_date.to_i)
    assert_equal('test/fixtures/iTunes.mp3', @item.file_path.to_s)
  end

  def test_tag
    assert_equal('iTunes Artist', @item.tag.artist)
    assert_equal('iTunes Genre', @item.tag.genre_s)
    assert_equal('iTunes Name', @item.tag.title)
    assert_equal(' 00007032 00006EA2 0000A049 00009735 00000559 0000096E 00008000 00008000 00000017 00000017', @item.tag.comments)
    assert_equal('iTunes Album', @item.tag.album)
    assert_equal(1970, @item.tag.year)
    assert_equal(42, @item.tag.tracknum)
  end

  def test_tag2
    assert_equal('iTunes Artist', @item.tag2.TP1)
    assert_equal('iTunes Genre', @item.tag2.TCO)
    assert_equal('iTunes Name', @item.tag2.TT2)
    assert_equal('iTunes Album', @item.tag2.TAL)
    assert_equal('1970', @item.tag2.TYE)
    assert_equal('iTunes Album Artist', @item.tag2.TP2)
    assert_equal('111', @item.tag2.TBP)
    assert_equal('42/99', @item.tag2.TRK)
    assert_equal('11', @item.tag2.TPA)
    assert_equal('iTunes Grouping', @item.tag2.TT1)
    assert_equal('iTunes Description (Video Pane)', @item.tag2.TT3)
    assert_equal('iTunes Composer', @item.tag2.TCM)
    assert_equal('iTunes Comments (Info Pane)', @item.tag2.COM[1])
  end

  def test_lyrics
    assert_equal(1, @item.lyrics.size)
    assert_equal("iTunes Lyrics Line 1\niTunes Lyrics Line 2", @item.lyrics['eng'])
  end
end
