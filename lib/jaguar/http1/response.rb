module Jaguar::HTTP1
  class Response
    CRLF = "\r\n"

    INITIALBODY=[]

    attr_accessor :status, :headers, :body

    def initialize
      @version = "HTTP/1.1"
      @status = 200
      @reason = "OK"
      @headers = {} 
      @body   = INITIALBODY 
    end

    def flush(sock)
      return if @done
      sock << "#{@version} #{@status} #{@reason}#{CRLF}"
      @headers.each do |k, v|
        sock << "#{k}: #{v}#{CRLF}"
      end
      @body.each do |chunk|
        sock << chunk
      end
      sock << "0#{CRLF * 2}"
    end

  end
end
