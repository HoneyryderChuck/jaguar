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

    def request(verb, path, headers: {})
      uri = URI(path)
      headers[":scheme"] = uri.scheme
      headers[":method"] = case verb
      when :get then "GET"
      end
      headers[":path"]   = uri.path
      @stream.headers(headers, end_stream: true)

      response 
    end

    
 
 
    def response
      read_data until @response and [:closed, :half_closed_remote].include?(@response.stream.state)
      @response   
    end
 
    def promise
      read_data until @promise and [:closed, :half_closed_remote].include?(@promise.stream.state)
      @promise
    end
 
    private

    def read_data
      data = @sock.readpartial(65_535)
      @conn << data
    end

    def on_frame(bytes)
      @sock.print bytes
      @sock.flush
    end
  
    def on_frame_sent(frame)
      LOG { "frame was sent!" }
      LOG { frame.inspect }
    end
    def on_frame_received(frame)
      LOG { "frame was received" }
      LOG { frame.inspect }
    end
    def on_promise(promise)
      @promise = Promise.new(promise)
    end

    def on_altsvc(frame)
      LOG { "altsvc frame was received" }
      LOG { frame.inspect }
    end

    def on_stream(stream)
      @response = Response.new(stream)
    end

    def LOG(&msg)
      return unless $JAGUAR_DEBUG 
      $stderr << "client: " + msg.call + "\n"
    end

    class Promise
      attr_reader :headers, :body, :stream
      def initialize(stream)
        @stream = stream
        @body = String.new
        @stream.on(:headers, &method(:on_headers))
        @stream.on(:data, &method(:on_data))
      end

      def status
        @headers[":status"].to_i
      end

      private
      def on_headers(headers)
        LOG { "received headers: #{headers}" }
        @headers = Hash[headers]
      end

      def on_data(data)
        LOG { "received data: #{data}" }
        @body << data
      end

      def LOG(&msg)
        return unless $JAGUAR_DEBUG 
        $stderr << "client promise: " + msg.call + "\n"
      end
    end
  
    class Response
      attr_reader :headers, :stream
    
      def initialize(stream)
        @body = String.new
        @stream = stream
        @stream.on(:close, &method(:on_close))
        @stream.on(:half_close, &method(:on_half_close))
        @stream.on(:altsvc, &method(:on_altsvc))
        @stream.on(:headers, &method(:on_headers))
        @stream.on(:data, &method(:on_data))
      end
   
      def body ; [@body] ; end 
   
      def status
        @headers[":status"].to_i
      end
 
      private
    
      def on_altsvc(f)
        LOG { "altsvc received!" }
      end
      def on_close(*)
        LOG { "stream is closed!" }
      end
      def on_half_close
        LOG { "stream is half closed" }
      end
      def on_headers(h)
        @headers = Hash[*h.flatten]
      end
      def on_data(data)
        @body << data
      end    
      def LOG(&msg)
        return unless $JAGUAR_DEBUG 
        $stderr << "client response: " + msg.call + "\n"
      end
    end      
             
  end        
end
