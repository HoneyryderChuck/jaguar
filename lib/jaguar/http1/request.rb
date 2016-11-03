require "jaguar/http1/parser"

module Jaguar::HTTP1
  #
  # the request MUST respond to:
  # * #verb (returns a String ("GET", "POST"...)
  # * #request_url (returns a URL)
  # * #headers (returns an headers hash)
  # * #body (returns an Enumerable)
  # 
  class Request
    extend Forwardable

    BUFFER_SIZE = 16_384

    def_delegators :@parser, :verb, :http_version,
                             :url, :headers
    alias_method :version, :http_version

    def initialize(sock)
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
