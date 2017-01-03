module Jaguar::HTTP1
  BUFFER_SIZE = 16_384
  ConnectionError = Class.new(StandardError)
  class Handler

    def initialize(transport, initial: nil, &action)
      @transport = transport
      @parser = Parser.new
      @action = action
      @parser << initial if initial
    end

    def handle_request
      headers = read_headers!
      request = Request.new(@parser, body.to_a)
      response = Response.new

      case request.headers["upgrade"]
      when "h2c"
        if request.headers["http2-settings"]
          response.status = 101
          response.headers["connection"] = "Upgrade" 
          response.headers["upgrade"] = "h2c"
          response.flush(@transport)
          throw(:upgrade, ["h2c", request]) 
        end
      when nil # ignore, no upgrades
      else
        # TODO: what to do if upgrade is not supported? 
      end
      @action.call(request, response)
      response.post_process(request)

      response.flush(@transport)

      LOG { "HTTP1 #{request.url} -> #{response.status}" }
      case response.headers["connection"]
      when "keep-alive"
        @parser.reset
        true
      when "close", nil
        false 
      end
    end


    private

    def body
      Enumerator.new do |y|
        chunk = @parser.chunk
        y << chunk if chunk
        while !((read(BUFFER_SIZE) == :eof) || @parser.finished?)
          chunk = @parser.chunk
          y << chunk
        end
      end
    end


    def read_headers!
      loop do
        if read(BUFFER_SIZE) == :eof
          raise ConnectionError, "couldn't read request" unless @parser.headers?
          break
        elsif @parser.headers?
          break
        end
      end
      @parser.headers
    end

    def read(bufsize)
      return if @parser.finished?

      value = @transport.readpartial(bufsize)
      case value
      when String
        @parser << value
      when :eof
        :eof
      end
    rescue EOFError
      :eof
    rescue IOError, SocketError, SystemCallError => ex
      raise "error reading from socket: #{ex}", ex.backtrace
    end

    def LOG(&msg)
      return unless $JAGUAR_DEBUG 
      $stderr << "server: " + msg.call + "\n"
    end
  end
end
