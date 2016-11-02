require_relative "../test_helper"
require "reqrep/test/request_lint"

class HTTP1RequestTest < Minitest::Test
  include ReqRep::Test::RequestLint

  private

  def request
    @request ||= Jaguar::HTTP1::Request.new(sock)
  end

  def sock
    mock = Minitest::Mock.new
    mock.expect(:readpartial, "GET / HTTP/1.1\r\n", [16_384])    
    mock.expect(:readpartial, "Host: github.com\n\n", [16_384])    
    mock.expect(:readpartial, "GET / Accept: */*\n\n", [16_384])    
    mock.expect(:readpartial, "\r\n", [16_384])
    mock.expect(:readpartial, "\r\n", [16_384])
    mock  
  end

end

