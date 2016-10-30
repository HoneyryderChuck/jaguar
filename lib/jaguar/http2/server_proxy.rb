module Jaguar::HTTP2
  class ServerProxy
    def initialize(transport, &action)
      @transport = transport
      @action = action
      @server = ::HTTP2::Server.new
      @server.on(:frame, &method(:on_frame))
      @server.on(:frame_sent, &method(:on_frame_sent))
      @server.on(:frame_received, &method(:on_frame_received))
      @server.on(:stream, &method(:on_stream))
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
      puts "Sent frame: #{frame.inspect}"
    end

    def on_frame_received(frame)
      puts "Received frame: #{frame.inspect}"
    end

    def on_stream(stream)
      puts "streaming!!!"
      str = Stream.new(stream, &@action)
    end

    class Stream
      attr_reader :headers, :buffer
      def initialize(stream, &action)
        @http_stream = stream
        @buffer = String.new
        @action = action
        stream.on(:active, &method(:on_active))
        stream.on(:closed, &method(:on_close))
        stream.on(:headers, &method(:on_headers))
        stream.on(:data, &method(:on_data))
        stream.on(:half_close, &method(:on_half_close))
      end

      def stream ; @http_stream ; end

      def on_active
      
      end

      def on_close
      end

      def on_headers(h)
       @headers = Hash[h] 
      end

      def on_data(data)
        @buffer << data
      end

      def on_half_close
        @action.call(self)
      end
    end
  end
end
