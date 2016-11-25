
module Jaguar::HTTP1
  CRLF = "\r\n"
  class Response

    attr_reader :headers
    attr_accessor :status, :body

    def initialize(status: 200, headers: Headers.new, body: [])
      @status = status
      @headers = headers
      @body   = Array(body) 
    end

    
    def flush(sock)
      sock = sock
      return if @done
      write(sock, "HTTP/1.1 #{@status} #{reason}#{CRLF}")
      @headers.each_capitalized do |k, v|
        write(sock, "#{k}: #{v}#{CRLF}")
      end
      write(sock, CRLF)
      @body.each do |chunk|
        write(sock, chunk)
      end if @body
    end


    private

    def write(sock, payload)
      LOG { payload }
      sock.write(payload)
    end

    def reason
      WEBrick::HTTPStatus::StatusMessage[@status]
    end

    def LOG(&msg)
      return unless $JAGUAR_DEBUG
      $stderr << "server response: " + msg.call.inspect + "\n"
    end
  end
end
