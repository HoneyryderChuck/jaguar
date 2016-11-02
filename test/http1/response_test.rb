require "test_helper"
require "reqrep/test/response_lint"

class HTTP1ResponseTest < Minitest::Test
  include ReqRep::Test::ResponseLint

  def response
    @response ||= Jaguar::HTTP1::Response.new
  end
end

