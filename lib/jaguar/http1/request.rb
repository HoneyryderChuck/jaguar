require "jaguar/http1/parser"

module Jaguar::HTTP1
  class Request
    extend Forwardable

    BUFFER_SIZE = 16_384

    def_delegators :@parser, :method, :status_code, :http_version,
                             :request_url, :headers, :body
    alias_method :version, :http_version

    def initialize(sock, **options)
      @sock = sock
      @parser = Parser.new
      read_headers!
    end

    def body
      Enumerator.new do |y|
        while !((read(BUFFER_SIZE) == :eof) || @parser.finished?)
          chunk = @parser.chunk
          y << chunk
        end
        @parser.reset
      end
    end 

    private


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

      value = @sock.readpartial(bufsize)
      case value
      when String
        @parser << value
      when :eof
        :eof
      end
    rescue IOError, SocketError, SystemCallError => ex
      raise "error reading from socket: #{ex}", ex.backtrace
    end
  end
end
