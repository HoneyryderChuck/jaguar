module Requests
  module KeepAliveGet
    def test_keep_alive
 
      server = app.send(:build_server, keep_alive_timeout: 2)
      server.run do |req, rep|
        if req.url == "/"
          rep.body = %w(Right)
          rep.headers["content-length"] = rep.body.map(&:bytesize).reduce(:+)
        else
          rep.status = 400
          rep.body = %w(Wrong)
          rep.headers["content-length"] = rep.body.map(&:bytesize).reduce(:+)
        end
      end 

      response = client.request(:get,"#{server_uri}/", headers: keep_alive_headers)
      assert response.status == 200, "response status code is unexpected"

      assert server.num_connections == 1

      response2 = client.request(:get,"#{server_uri}/", headers: keep_alive_headers)
      assert response2.status == 200, "response status code is unexpected"
      assert server.num_connections == 1
      sleep 2

      assert server.num_connections == 0
    ensure
      server.stop if server
    end

    private

    def keep_alive_headers
      {"accept" => "*/*", "connection" => "keep-alive"}
    end
  end
end
