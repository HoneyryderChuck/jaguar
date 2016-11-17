module Requests
  module PushGet

    Promise = Struct.new(:status, :headers, :body)

    def test_push_get
      server.run do |req, rep|
        if req.url == "/"
          rep.body = %w(Right)
          rep.headers["content-type"] = "text/plain"
          rep.headers["content-length"] = 5

          promise = Promise.new(200, 
                                {"content-length" => "4", 
                                 "content-type"   => "text-plain"}, 
                                 %w(Time))

          rep.push "/resource", promise
        else
          rep.status = 400
          rep.headers["content-type"] = "text/plain"
          rep.headers["content-length"] = 5
          rep.body = %w(Wrong)
        end
      end 

      response = client.request(:get,"#{server_uri}/", headers: {"accept" => "*/*"})

      assert response.status == 200, "response status code is unexpected"
      assert response.headers["content-length"].include?("5"), "response content length is unexpected"
      assert response.body == "Right", "response body is unexpected"

      sleep 1
      promise = client.promise

      assert promise.status == 200, "promise status code is unexpected"
      assert promise.headers["content-length"].include?("4"), "promise content length is unexpected"
      assert promise.body == "Time", "promise body is unexpected"
      
    ensure
      client.close if client
    end


  end
end

