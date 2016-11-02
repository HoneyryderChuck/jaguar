require_relative "../test_helper"
require "reqrep/test/request_lint"

class HTTP2RequestTest < Minitest::Test
  include ReqRep::Test::RequestLint

  def request
    @request ||= begin
      req = Jaguar::HTTP2::Request.new(stream)
      # streams set the method and path in the headers
      req.instance_variable_set(:@headers, {})
      req.headers[":method"] = "GET"
      req.headers[":path"] = "/random"
      req
    end
  end

  def stream
    mock = Minitest::Mock.new
    mock.expect(:on, nil, [:active])
    mock.expect(:on, nil, [:closed])
    mock.expect(:on, nil, [:headers])
    mock.expect(:on, nil, [:data])
    mock.expect(:on, nil, [:half_close])
  end
end
