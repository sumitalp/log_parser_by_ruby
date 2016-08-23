require 'test/unit'
require_relative '../log_parser.rb'


class TestLogParser < Test::Unit::TestCase
  def setup
    @log_parser = LogfileParser.new
  end

  def test_file_exists?
    assert_equal(@log_parser.file_exists?, TRUE)
  end

  def test_empty_final_hash
    parser = LogfileParser.new
    assert_empty(parser.final_hash['count_pending']['dyno'], msg='After Initialization, final_hash will be empty')
  end

  def test_final_hash_after_output
    @log_parser.prepare_hash
    refute_empty(@log_parser.final_hash['count_pending']['dyno'], msg='After get an output, final_hash will fill with data')
  end

  def teardown
    @log_parser = nil
  end
end