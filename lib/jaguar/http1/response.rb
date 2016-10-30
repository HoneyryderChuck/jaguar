module Jaguar
  class Response
    CRLF = "\r\n"

    def initialize(proxyres)
      @version = "HTTP/1.1"
      @status = proxyres.status
      @reason = "OK"
      @headers = proxyres.headers
      @body   = proxyres.body
      @proxy = proxyres
     end


    def each
      yield "#{@version} #{@status} #{@reason}#{CRLF}"
      @headers.each do |k, v|
        yield "#{k}: #{v}#{CRLF}"
      end
      @body.each do |chunk|
        yield chunk
      end
      yield "0#{CRLF * 2}"
    end 
  end
end
