module Jaguar::HTTP1
  class Response
    CRLF = "\r\n"

    def initialize(proxyres, sock)
      @version = "HTTP/1.1"
      @status = proxyres.status
      @reason = "OK"
      @headers = proxyres.headers
      @body   = proxyres.body
      @proxy = proxyres
      @sock = sock

      @done = false
    end

    def flush
      return if @done
      @sock << "#{@version} #{@status} #{@reason}#{CRLF}"
      @headers.each do |k, v|
        @sock << "#{k}: #{v}#{CRLF}"
      end
      @body.each do |chunk|
        @sock << chunk
      end
      @sock << "0#{CRLF * 2}"
    ensure
      @done = true
    end

  end
end
