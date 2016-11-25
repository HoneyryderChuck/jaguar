module Jaguar::HTTP1
  BUFFER_SIZE = 16_384
  class Handler

    def initialize(transport, initial: nil, &action)
      @transport = transport
      @parser = Parser.new
      @parser << initial if initial
      read_headers!
      request = Request.new(@parser, body)
      response = Response.new
      case request.headers["Upgrade"]
      when "h2c"
        if request.headers["http2-settings"]
          response.status = 101
          response.headers["Connection"] = "Upgrade" 
          response.headers["Upgrade"] = "h2c"
          response.flush(@transport)
          throw(:upgrade, ["h2c", request]) 
        end
      when nil # ignore, no upgrades
      else
        # TODO: what to do if upgrade is not supported? 
      end
      action.call(request, response) 
    end


    private

    def body
      Enumerator.new do |y|
        while !((read(BUFFER_SIZE) == :eof) || @parser.finished?)
          chunk = @parser.chunk
          y << chunk
        end
        @parser.reset
      end
    end


    def read_headers!
      loop do
        if read(BUFFER_SIZE) == :eof
          raise "couldn't read headers" unless @parser.headers?
          break
        elsif @parser.headers?
          break
        end
      end
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
    rescue IOError, SocketError, SystemCallError => ex
      raise "error reading from socket: #{ex}", ex.backtrace
    end

    def LOG(&msg)
      return unless $JAGUAR_DEBUG 
      $stderr << "server: " + msg.call + "\n"
    end
  end
end
