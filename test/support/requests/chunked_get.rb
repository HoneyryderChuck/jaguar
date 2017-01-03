module Requests
  module ChunkedGet

    def test_chunked_get
      server.run do |req, rep|
        rep.body = %w(Left Right)
      end 

      response = client.request(:get,"#{server_uri}/", headers: {"accept" => "*/*"})

      assert response.status == 200, "response status code is unexpected"
      assert response.headers["transfer-encoding"].include?("chunked"), "response hasn't been chunked"
      assert response.body == %w(LeftRight), "response body is unexpected"
    end


  end
end

