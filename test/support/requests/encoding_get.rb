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
      assert transfer_encoding(response) != nil, "response encoding is unexpected"
      assert transfer_encoding(response).include?("gzip"), "response encoding is unexpected"
    end

    def test_encoding_deflate
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
                                               "accept-encoding" => "deflate"})

      assert response.status == 200, "response status code is unexpected"
      assert transfer_encoding(response) != nil, "response encoding is unexpected"
      assert transfer_encoding(response).include?("deflate"), "response encoding is unexpected"
    end


    def transfer_encoding(response)
      v = response.headers["transfer-encoding"]
      if v.is_a?(Array)
        # thank you, net/http
        v = v.flat_map do |enc|
          enc.split(/\s*,\s*/)
        end
      end
      v
    end
  end
end

