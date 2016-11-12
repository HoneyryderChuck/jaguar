require_relative "../test_container"

class Jaguar::HTTP2::HTTPServerTest < ContainerTest
  def setup
    Celluloid.init
    @app = Jaguar::Container.new("http://127.0.0.1:8989")
  end

  def test_get
    server = @app.send(:build_server)
    server.run(&method(:get_app))

    client = http_client
    response = get_request(client)
    assert response.status == 200, "response is unexpected"
    assert response.headers[":content-length"] == "5", "response is unexpected"
    assert response.body == "Right", "response is unexpected"
  ensure
    client.close if client 
    server.stop if server
  end



  private

  def server_uri
    "http://127.0.0.1:8989"
  end

  def http_client
    uri = URI(server_uri)
    sock = TCPSocket.new(uri.host, uri.port)
    Jaguar::HTTP2::Client.new(sock)
  end

  def get_app(req, rep)
    if req.url == "/"
      rep.body = %w(Right)
      rep.headers[":content-length"] = rep.body.map(&:bytesize).reduce(:+)
    else
      rep.status = 400
      rep.headers["content-length"] = rep.body.map(&:bytesize).reduce(:+)
      rep.body = %w(Wrong)
    end
  end


  def get_request(client)
    headers = { "accept" => "*/*"}
    client.request(:get, "#{server_uri}/", headers: headers)
  end
end

