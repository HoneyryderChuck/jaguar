module Requests
  module DecodingPost

    def test_decoding_gzip
      server.run do |req, rep|
        if req.body.include?("right")
          rep.body = %w(Right)
          rep.headers["content-length"] = rep.body.map(&:bytesize).reduce(:+)
        else
          rep.status = 400
          rep.body = %w(Wrong)
          rep.headers["content-length"] = rep.body.map(&:bytesize).reduce(:+)
        end
      end
 
      response = client.request(:post,"#{server_uri}/", 
                                       headers: {"accept" => "*/*",
                                                 "transfer-encoding" => "gzip"}, body: "right")

      assert response.status == 200, "response status code is unexpected"
      assert response.body.include?("Right"), "response body is unexpected"
    end
  end
end
