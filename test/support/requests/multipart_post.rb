module Requests
  module MultipartPost

    # this test doens't do much mores than the plain post.
    # however, one has to have a solution for when the upload is giganormous, as
    # the VM might fall. File buffering?
    def test_multipart_post
      file = File.read("test/support/fixtures/jaguar.jpg", encoding: "ASCII-8BIT")
      server.run do |req, rep|
        if req.headers["content-type"].include?("multipart/form-data") &&
           req.body.to_a.join.include?(file)
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

      boundary = "a234e2r523324"
      headers = { "content-type" => "multipart/form-data, boundary=#{boundary}"}
      body = String.new
      body << "--#{boundary}\r\n"
      body << "Content-Disposition: form-data; name=\"upload\"; filename=\"jaguar.jpg\"\r\n"
      body << "Content-Type: image/jpg\r\n\r\n"
      body << file
      body << "\r\n\r\n"
      body << "--#{boundary}--\r\n"

      response = client.request(:post, "#{server_uri}/", headers: headers, body: file)

      assert response.status == 200, "response status code is unexpected"
      assert response.body == %w(Right), "response body is unexpected"

    ensure
    end


  end
end


