module Jaguar::HTTP2
  class Client
    def initialize(sock)
      @sock = sock
      @conn = HTTP2::Client.new
      @stream = @conn.new_stream
      @response = Response.new(@stream)
  
      @conn.on(:frame, &method(:on_frame))
      @conn.on(:frame_sent, &method(:on_frame_sent))
      @conn.on(:frame_received, &method(:on_frame_received))
      @conn.on(:promise, &method(:on_promise))
      @conn.on(:altsvc, &method(:on_altsvc))
    end
 
    def close
      @sock.close
    end
 
    def write(h)
      @stream.headers(h, end_stream: true)
    end
  
    def response

      until @response.stream.state == :closed
        data = @sock.readpartial(65_535)
        @conn << data
      end

      @response   
    end
  
    private
  
    def on_frame(bytes)
      @sock.print bytes
      @sock.flush
    end
  
    def on_frame_sent(frame)
     # puts "frame was sent!"
    end
    def on_frame_received(frame)
     # puts "frame was received"
    end
    def on_promise(promise) ; ; end
    def on_altsvc(f) ; ; end
  
  
    class Response
      attr_reader :headers, :body, :stream
    
      def initialize(stream)
        @body = []
        @stream = stream
        @stream.on(:close, &method(:on_close))
        @stream.on(:half_close, &method(:on_half_close))
        @stream.on(:headers, &method(:on_headers))
        @stream.on(:data, &method(:on_data))
        @stream.on(:altsvc, &method(:on_altsvc))
      end
    
   
      def status
        @headers[":status"].to_i
      end
 
      private
    
      def on_altsvc(f)
       # puts "altsvc received!"
      end
      def on_close(*)
       # puts "stream is closed!"
      end
      def on_half_close
       # puts "stream is half closed"
      end
      def on_headers(h)
        @headers = Hash[*h.flatten]
      end
      def on_data(data)
        @body << data
      end
    end
  
  end
end
