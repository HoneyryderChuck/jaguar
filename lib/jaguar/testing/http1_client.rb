module Jaguar::HTTP1
  class Client
  
    attr_reader :response
    def initialize(sock)
      @sock = sock
      @parser = Parser.new
    end

    def close
      @sock.close
      @parser.reset
    end 
 
    def write(headers)
      @sock.write "#{headers.delete(":method")} #{headers.delete(":path")} HTTP/1.1#{CRLF}"
      headers.each do |k, v|
        @sock.write "#{k.capitalize}: #{v}#{CRLF}"
      end
      @sock.write(CRLF * 2)
    end
  
  
    def response
      res = String.new
      # read headers
      while data = read(BUFFER_SIZE)
        break if data == :eof || @parser.headers?
        @parser << data
      end

      body = [@parser.chunk].compact
      while !@parser.finished?
        data = read(BUFFER_SIZE)
        break if data == :eof
        @parser << data
        body << @parser.chunk
      end
      Response.new(status: @parser.status_code,
                   headers: @parser.headers,
                   body: body)
      
    end

    def read(bufsize)
      loop do
        data = @sock.read_nonblock(bufsize, exception: false)
        case data
        when nil then return :eof
        when :wait_readable
          @sock.wait_readable
        else return data
        end
      end
    end
  end
end
