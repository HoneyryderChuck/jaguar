module Jaguar
  class Server

    def initialize(server_proxy, **options)
      @options = options
      @reactor = Reactor.new(server_proxy, **options)
    end

    def run(&action)
      @reactor.async(:run, action)
    end


    def stop
      @reactor.stop if @reactor and @reactor.alive?
    end

  end
end
