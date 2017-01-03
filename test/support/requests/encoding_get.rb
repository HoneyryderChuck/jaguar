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
      assert vary(response).include?("accept-encoding") ||
             vary(response).include?("Accept-Encoding"), "vary headers is unexpected"
      assert transfer_encoding(response) != nil, "response encoding is unexpected"
      assert transfer_encoding(response).include?("gzip"), "response encoding is unexpected"
    end

    def test_encoding_gzip
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
                                               "accept-encoding" => "gzip"})

      assert response.status == 200, "response status code is unexpected"
      assert vary(response).include?("accept-encoding") ||
             vary(response).include?("Accept-Encoding"), "vary headers is unexpected"
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
      assert vary(response).include?("accept-encoding") ||
             vary(response).include?("Accept-Encoding"), "vary headers is unexpected"
      assert transfer_encoding(response) != nil, "response encoding is unexpected"
      assert transfer_encoding(response).include?("deflate"), "response encoding is unexpected"
    end


    def test_encoding_identity
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
                                               "accept-encoding" => "identity"})

      assert response.status == 200, "response status code is unexpected"
      assert vary(response).include?("accept-encoding") ||
             vary(response).include?("Accept-Encoding"), "vary headers is unexpected"
      assert transfer_encoding(response) == nil, "response encoding is unexpected"
    end

    private

    def vary(response)
      parse_multivalue_headers(response.headers["vary"])
    end

    def transfer_encoding(response)
      parse_multivalue_headers(response.headers["transfer-encoding"])
    end

    def parse_multivalue_headers(header)
     if header.is_a?(Array)
       # thank you, net/http
       header.flat_map do |enc|
         enc.split(/\s*,\s*/)
       end
     else
       header
     end
    end
  end
end

