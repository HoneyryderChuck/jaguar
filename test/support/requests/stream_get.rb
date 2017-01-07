module Requests
  module StreamGet

    def test_stream_get
      server.run do |req, rep|
        streamio = rep.stream!
        streamio.emit_data("bang", false)
        sleep 0.5
        streamio.emit_data("bang2")
        streamio.close
      end

      sleep 1 

      response = client.request(:get,"#{server_uri}/", headers: {"accept" => "text/event-stream"})

      assert response.status == 200, "response status code is unexpected"
      assert response.headers["content-type"].include?("text/event-stream; charset=utf-8"), "response hasn't been streamed"
      assert response.headers["cache-control"].include?("no-cache"), "response hasn't disabled cache"
     assert response.body.join == "data: bang\ndata: bang2\n\n", "response body is unexpected"
    end


  end
end


