module Jaguar::HTTP2
  class ServerProxy
    def initialize(transport, initial: nil, &action)
      @transport = transport
      @server = ::HTTP2::Server.new
      @server.on(:frame, &method(:on_frame))
      @server.on(:frame_sent, &method(:on_frame_sent))
      @server.on(:frame_received, &method(:on_frame_received))
      @server.on(:stream, &action)
      @server << initial if initial
      loop do
        data = transport.readpartial(4096)
        @server << data
      end
    rescue EOFError
      @transport.close
    end


    def on_frame(bytes)
      @transport.write bytes
    end

    def on_frame_sent(frame)
      # puts "Sent frame: #{frame.inspect}"
    end

    def on_frame_received(frame)
      # puts "Received frame: #{frame.inspect}"
    end
  end
end
