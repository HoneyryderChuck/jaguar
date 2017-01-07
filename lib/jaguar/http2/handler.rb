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
      end
    end

    def <<(bytes)
      @server << bytes
    end

    private
    def on_frame(bytes)
      @transport.write bytes
    end

    def on_frame_sent(frame)
       LOG { "frame was sent!" }
       LOG { frame.inspect } 
    end

    def on_frame_received(frame)
      LOG { "frame was received" }
      LOG { frame.inspect }
    end

    def on_stream(stream)
      Request.new(stream) do |request|
        response = Response.new
        @action.call(request, response)
        response.post_process(request)
        response.flush(stream)
        LOG{ "HTTP2 #{request.url} -> #{response.status}" }
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
      }.merge(HTTP2::Headers.new(headers))
      @server.upgrade(settings ,request, http1_request.body)
      
    end

    def LOG(&msg)
      return unless $JAGUAR_DEBUG 
      $stderr << "server: " + msg.call + "\n"
    end
  end
end
