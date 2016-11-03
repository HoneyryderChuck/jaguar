module Jaguar
  class Server

    def initialize(server_proxy, **options)
      @options = options
      @reactor = Reactor.new(server_proxy, **options)
      @action = options.fetch(:action)
    end

    def run
      @reactor.run(@action)
    end


    def stop
      @reactor.stop if @reactor
    end

  end
end
