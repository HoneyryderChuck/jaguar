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
      req = Request.new(sock)
      res = action.call(req)
      Response.new(res).each do |chunk|
        sock << chunk
      end
      sock.close # TODO: keep-alive 
    end
  end
end

