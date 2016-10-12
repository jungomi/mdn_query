require 'test_helper'

class MdnQueryTest < Minitest::Test
  def test_version_number
    refute_nil ::MdnQuery::VERSION
    assert ::MdnQuery::VERSION > '0.0.0'
  end
end
