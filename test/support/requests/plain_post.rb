module Requests
  module PlainPost

    def test_post
      server.run do |req, rep|
        if req.body.include?("right")
          status = 200
          body = "Right"
             
        else
          status = 404
          body = "Wrong"
        end
        rep.status = status
        rep.body = [body]
        rep.headers["content-length"] = body.bytesize
      end 


      response = client.request(:post,"#{server_uri}/", headers: {"accept" => "*/*"}, body: "right")

      assert response.status == 200, "response status code is unexpected"
      assert response.body == %w(Right), "response body is unexpected"



      response = client.request(:post,"#{server_uri}/", headers: {"accept" => "*/*"}, body: "wrong")

      assert response.status == 404, "response status code is unexpected"
      assert response.body == %w(Wrong), "response body is unexpected"
    end


  end
end

