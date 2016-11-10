module Jaguar
  class Reactor 
    include Celluloid::IO

    def initialize(proxy, **options)
      @options = options
      @server = Socket.try_convert(proxy)
      @server.listen(1024)
    end

    def run(action)
      loop do 
        async(:handle_connection, @server.accept, action)
      end
    rescue IOError
    end


    def stop
      @server.close if !@server.closed?
    end

    private

    def handle_connection(sock, action)
      data = sock.readpartial(1024)
      if is_http1?(data)
        req = HTTP1::Request.new(sock, initial: data)
        res = HTTP1::Response.new
        action.call(req, res)
        res.flush(sock)
        sock.close # TODO: keep-alive 
      else
        HTTP2::ServerProxy.new(sock, initial: data) do |stream|
          HTTP2::Request.new(stream) do |req|
            res = HTTP2::Response.new
            action.call(req, res)
            res.flush(stream)
          end
          # TODO: PUSH data here
        end
      end
    rescue Errno::ECONNRESET
      puts "socket closed by the client"
      sock.close
    end

    def is_http1?(data)
      data.match(/\A\w+ .* HTTP\/1\./)
    end

#    def handle_connection(sock, action)
#      req = HTTP1::Request.new(sock)
#      res = action.call(req)
#      HTTP1::Response.new(res).flush(sock)
#      sock.close # TODO: keep-alive 
#    end
  end
end

