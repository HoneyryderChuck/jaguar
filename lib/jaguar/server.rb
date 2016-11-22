module Jaguar
  class Server

    def initialize(server_proxy, **options)
      @options = options
      @reactor = Reactor.supervise(as: :reactor, args: [server_proxy, options])
    end

    def run(&action)
      Celluloid::Actor[:reactor].async(:run, action)
    end


    def stop
      @reactor.shutdown if @reactor and @reactor.alive?
    end

  end
end
