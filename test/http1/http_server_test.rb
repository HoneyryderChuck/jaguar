require_relative "../test_container"

class Jaguar::HTTP1::HTTPServerTest < ContainerTest

  def test_get
    server = @app.send(:build_server)
    server.run(&method(:get_app))

    client = http_client
    response = get_request(client)
    assert response.status == 200, "response status code is unexpected"
    assert response.headers["content-length"].include?("5"), "response content length is unexpected"
    assert response.body == "Right", "response body is unexpected"
  ensure
    client.close if client
    server.stop if server
  end



  private
  def setup
    Celluloid.init
    @app = Jaguar::Container.new(server_uri)
  end

  def server_uri
    "http://127.0.0.1:8989"
  end

  def http_client
    uri = URI(server_uri)
    conn = Net::HTTP.new(uri.host, uri.port)
    Jaguar::HTTP1::Client.new(conn)
  end

  def get_app(req, rep)
    if req.url == "/"
      rep.body = %w(Right)
      rep.headers["Content-Length"] = rep.body.map(&:bytesize).reduce(:+)
    else
      rep.status = 400
      rep.headers["Content-Length"] = rep.body.map(&:bytesize).reduce(:+)
      rep.body = %w(Wrong)
    end
  end


  def get_request(client)
    headers = { "accept" => "*/*"}
    client.request(:get, "#{server_uri}/", headers: headers)
  end
end
