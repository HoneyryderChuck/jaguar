module Jaguar
  class Reactor 
    include Celluloid::IO

    def initialize(host, port, **options)
      @options = options
      @server = TCPServer.new(host, port)
      @server.listen(1024)
    end

    def run(action)
      loop { async(:handle_connection, @server.accept, action) }
    end


    def stop
      @server.close if @server
    end

    private

    def handle_connection(sock, action)
      HTTP2::ServerProxy.new(sock) do |stream|
        HTTP2::Request.new(stream) do |req|
          res = HTTP2::Response.new
          action.call(req, res)
          res.flush(stream)
        end
        # TODO: PUSH data here
      end
    rescue Errno::ECONNRESET
      puts "socket closed by the client"
      sock.close
    end

#    def handle_connection(sock, action)
#      req = HTTP1::Request.new(sock)
#      res = action.call(req)
#      HTTP1::Response.new(res).flush(sock)
#      sock.close # TODO: keep-alive 
#    end
  end
end

