require_relative "../test_helper"
require "reqrep/test/request_lint"

class HTTP1RequestTest < Minitest::Test
  include ReqRep::Test::RequestLint

  def test_parse_simple
    payload = "GET /?a=1 HTTP/1.1\r\n\r\n"
    request = Jaguar::HTTP1::Request.new(parser(payload), [])


#    assert_equal '/', req['REQUEST_PATH']
    assert request.version == '1.1'
    assert request.url == '/?a=1'
    assert request.verb == 'GET'
  end

  def test_parse_escaping_in_query
    payload = "GET /admin/users?search=%27%%27 HTTP/1.1\r\n\r\n"
    request = Jaguar::HTTP1::Request.new(parser(payload), [])
    assert request.url == '/admin/users?search=%27%%27'
  end

  def test_parse_absolute_uri
    payload = "GET http://192.168.1.96:3000/api/v1/matches/test?1=1 HTTP/1.1\r\n\r\n"
    request = Jaguar::HTTP1::Request.new(parser(payload), [])
    assert request.verb == "GET"
    assert request.url == 'http://192.168.1.96:3000/api/v1/matches/test?1=1'
    assert request.version == '1.1'
  end

  def test_parse_dumbfuck_headers
    payload = "GET / HTTP/1.1\r\naaa:+++\r\n\r\n"
    request = Jaguar::HTTP1::Request.new(parser(payload),[])
    assert request.verb == "GET"
    assert request.url == "/"
    assert request.version == '1.1'
    assert request.headers["aaa"] == "+++"
  end

  def test_parse_error
    payload = "GET / SsUTF/1.1"
    error = false
    begin
      request = Jaguar::HTTP1::Request.new(parser(payload),[])
    rescue
      error = true 
    end

    assert error, "failed to throw exception"
  end

  def test_fragment_in_uri
    payload = "GET /forums/1/topics/2375?page=1#posts-17408 HTTP/1.1\r\n\r\n"
    request = Jaguar::HTTP1::Request.new(parser(payload),[])
    assert request.url, '/forums/1/topics/2375?page=1'
  end

  private

  def request
    @request ||= Jaguar::HTTP1::Request.new(parser, [])
  end

  def parser(payload=nil)
    parser = Jaguar::HTTP1::Parser.new
    payload ||= "GET / HTTP/1.1\r\nHost: github.com\n\nGET / Accept: */*\r\n\r\n\r\n"
    parser << payload
    parser 
  end

end

