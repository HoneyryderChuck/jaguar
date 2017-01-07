module Requests
  module UnsupportedVersions 

    def test_10_get
      body = "Right"
      server.run do |req, rep|
        rep.body = [body]
        rep.headers["content-length"] = body.bytesize 
      end 

      response = client.request(:get,"#{server_uri}/", version: "1.0", 
                                                       headers: {"accept" => "*/*"})

      assert response.status == 505, "response status code is unexpected"
    end

  end
end
