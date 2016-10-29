module Jaguar
  class Server

    def initialize(host, port, **options)
      @options = options
      @reactor = Reactor.new(host, port, **options)
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
