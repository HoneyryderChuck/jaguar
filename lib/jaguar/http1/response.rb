module Jaguar::HTTP1
  CRLF = "\r\n"
  class Response

    INITIALBODY=[]

    attr_accessor :status, :headers, :body

    def initialize(status: 200, headers: Headers.new, body: [])
      @version = "HTTP/1.1"
      @status = status
      @reason = "OK" # make this dynamic 
      @headers = headers
      @body   = body 
    end

    
    def flush(sock)
      sock = sock
      return if @done
      sock.write "#{@version} #{@status} #{@reason}#{CRLF}"
      @headers.each do |k, v|
        sock.write "#{k}: #{v}#{CRLF}"
      end
      sock.write CRLF
      @body.each do |chunk|
        sock.write chunk
      end
    end

  end
end
