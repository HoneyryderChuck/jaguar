module Requests
  module EncodingGet

    def test_encoding_default
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

      response = client.request(:get,"#{server_uri}/", 
                                     headers: {"accept" => "*/*",
                                               "accept-encoding" => "*"})

      assert response.status == 200, "response status code is unexpected"
      assert response.headers["transfer-encoding"] != nil, "response encoding is unexpected"
      assert response.headers["transfer-encoding"].include?("gzip"), "response encoding is unexpected"
    end


  end
end

