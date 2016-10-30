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
        req = HTTP2::Request.new(stream.headers, stream.buffer)
        res = action.call(req)

        response = HTTP2::Response.new(res, stream.stream)
        response.flush
        # TODO: PUSH data here
      end
    end

#    def handle_connection(sock, action)
#      req = HTTP1::Request.new(sock)
#      res = action.call(req)
#      HTTP1::Response.new(res).each do |chunk|
#        sock << chunk
#      end
#      sock.close # TODO: keep-alive 
#    end
  end
end

