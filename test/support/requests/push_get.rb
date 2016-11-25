module Requests
  module PushGet

    Promise = Struct.new(:status, :headers, :body)

    def test_push_get
      assets_dir = Dir.mktmpdir("test_assets")
      File.open(File.join(assets_dir, "main.css"), "w+") { |f| f.write(".rule {}") } 

      server.run do |req, rep|
        if req.url == "/"
          rep.body = %w(Right)
          rep.headers["content-type"] = "text/plain"
          rep.headers["content-length"] = 5

          rep.headers.add_field("Link", "</main.css>; rel=preload; as=style")


          rep.enable_push!([assets_dir])
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
      assert response.body == %w(Right), "response body is unexpected"

      sleep 1
      promise = client.promise

      assert promise.status == 200, "promise status code is unexpected"
      assert promise.headers["content-type"].include?("text/css"), "promise content type is unexpected"
      assert promise.body == ".rule {}", "promise body is unexpected"
    ensure 
      FileUtils.rm_rf(assets_dir) if assets_dir
    end

  end
end

