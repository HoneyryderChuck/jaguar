module Requests
  module PlainGet

    def test_get
      server.run do |req, rep|
        if req.url == "/"
          rep.body = %w(Right)
          rep.headers["content-Length"] = rep.body.map(&:bytesize).reduce(:+)
        else
          rep.status = 400
          rep.headers["content-Length"] = rep.body.map(&:bytesize).reduce(:+)
          rep.body = %w(Wrong)
        end
      end 

client

      response = client.request(:get,"#{server_uri}/", headers: {"accept" => "*/*"})

      assert response.status == 200, "response status code is unexpected"
      assert response.headers["content-length"].include?("5"), "response content length is unexpected"
      assert response.body == "Right", "response body is unexpected"
    ensure
      client.close if client
    end


  end
end
