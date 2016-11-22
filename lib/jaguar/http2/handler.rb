module Jaguar::HTTP2
  class Handler 
    def initialize(transport, initial: nil, upgrade: nil, &action)
      @transport = transport
      @server = ::HTTP2::Server.new
      @action = action
      @server.on(:frame, &method(:on_frame))
      @server.on(:frame_sent, &method(:on_frame_sent))
      @server.on(:frame_received, &method(:on_frame_received))
      @server.on(:stream, &method(:on_stream))
      @server << initial if initial
      if upgrade
        upgrade!(upgrade)
      else
        loop do
          data = transport.readpartial(4096)
          @server << data
        end
      end
    rescue EOFError
      @transport.close
    end

    private
    def on_frame(bytes)
      @transport.write bytes
    end

    def on_frame_sent(frame)
      # puts "server: frame was sent!"
      # puts frame.inspect 
    end

    def on_frame_received(frame)
      #puts "server: frame was received"
      #puts frame.inspect 
    end

    def on_stream(stream)
      Request.new(stream) do |req|
        res = Response.new
        res.headers["referer"] = req.headers[":authority"]
        @action.call(req, res)
        res.headers["server"] = "jaguar"
        res.flush(stream)
      end
    end

    def upgrade!(http1_request)
      headers = http1_request.headers.to_hash
      settings = headers.delete("http2-settings")
      request = {
        ':scheme'    => 'http',
        ':method'    => http1_request.verb,
        ':authority' => headers.delete('host'),
        ':path'      => http1_request.url,
      }.merge(Headers.new(headers))
      # TODO: review that to_a, what if the request is streaming?
      @server.upgrade(settings ,request, Array(http1_request.body))
      
    end
  end
end
