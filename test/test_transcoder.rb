require_relative "test_helper"

class TranscoderTest < Minitest::Test
  def  test_selects_preferred_transcoder
    helper = lambda do |a, b|
      Jaguar::Transcoder.select(a, b)
    end

    assert helper.call(%w(), "x;q=1") == nil
    assert helper.call(%w(identity), "identity;q=0") == nil
    assert helper.call(%w(identity), "*;q=0.0") == nil
    assert helper.call(%w(identity), "compress;q=1.0,gzip;q=1.0") == "identity"
    assert helper.call(%w(compress gzip identity), "compress;q=1.0, gzip;q=1.0") ==  "compress"
    assert helper.call(%w(compress gzip identity), "compress;q=0.5, gzip;q=1.0") == "gzip"
    assert helper.call(%w(foo bar identity), "") == "identity"
    assert helper.call(%w(foo bar identity), "*;q=1.0") == "foo"
    assert helper.call(%w(foo bar identity), "*;q=1.0, foo;q=0.9") == "bar"

    helper.call(%w(foo bar identity), "foo;q=0, bar;q=0") == "identity"
    helper.call(%w(foo bar baz identity), "*;q=0, identity;q=0.1") == "identity"
  end
end
