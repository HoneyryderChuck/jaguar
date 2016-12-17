module Requests
  module ChunkedGet

    def test_chunked_get
      server.run do |req, rep|
        if req.url == "/"
          rep.body = %w(Left Right)
        else
          rep.status = 400
          rep.body = %w(Wrong)
          rep.headers["content-length"] = rep.body.map(&:bytesize).reduce(:+)
        end
      end 

      response = client.request(:get,"#{server_uri}/", headers: {"accept" => "*/*"})

      assert response.status == 200, "response status code is unexpected"
      assert response.headers["transfer-encoding"].include?("chunked"), "response hasn't been chunked"
      assert response.body == %w(LeftRight), "response body is unexpected"
    end


  end
end

