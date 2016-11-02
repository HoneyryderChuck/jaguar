require "test_helper"
require "reqrep/test/response_lint"

class HTTP2ResponseTest < Minitest::Test
  include ReqRep::Test::ResponseLint

  def response
    @response ||= Jaguar::HTTP2::Response.new
  end
end
