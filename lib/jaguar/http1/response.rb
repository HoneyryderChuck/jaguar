
module Jaguar::HTTP1
  CRLF = "\r\n"
  class Response < Jaguar::HTTP::Response

    def initialize(status: 200, headers: Headers.new, body: [])
      super
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

    def post_process(request)
      super
    end

    private

    def write(sock, payload)
      LOG { payload }
      sock.write(payload)
    end

  end
end
