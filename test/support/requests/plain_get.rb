module Requests
  module PlainGet

    def test_get
      body = "Right"
      server.run do |req, rep|
        rep.body = [body]
        rep.headers["content-length"] = body.bytesize 
      end 

      response = client.request(:get,"#{server_uri}/", headers: {"accept" => "*/*"})

      assert response.status == 200, "response status code is unexpected"
      assert response.headers["content-length"].include?("5"), "response content length is unexpected"
      assert response.body == [body], "response body is unexpected"
    end


  end
end
