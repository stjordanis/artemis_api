require "test_helper"

class ArtemisApiTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ArtemisApi::VERSION
  end
end
