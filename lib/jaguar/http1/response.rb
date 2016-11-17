
module Jaguar::HTTP1
  CRLF = "\r\n"
  class Response

    attr_reader :headers
    attr_accessor :status, :body

    def initialize(status: 200, headers: Headers.new, body: [])
      @status = status
      @headers = headers
      @body   = nil 
    end

    
    def flush(sock)
      sock = sock
      return if @done
      sock.write "HTTP/1.1 #{@status} #{reason}#{CRLF}"
      @headers.each do |k, v|
        sock.write "#{k}: #{v}#{CRLF}"
      end
      sock.write CRLF
      @body.each do |chunk|
        sock.write chunk
      end if @body
    end


    private

    def reason
      WEBrick::HTTPStatus::StatusMessage[@status]
    end
  end
end
