require "jaguar"
require "reqrep/handler"

module ReqRep
  module Handler
    module Jaguar 
      DEFAULT_OPTIONS = {
        :Verbose => false,
        :Silent  => false
      }

      def self.run(app, **options)
        host = options.delete(:host)
        port = options.delete(:port)

        server = ::Jaguar::Server.new(TCPServer.new(host, port), options.merge(action: app))               

        begin
          server.run
        rescue Interrupt
          puts "* Gracefully stopping, waiting for requests to finish"
          server.stop
          puts "* Goodbye!"
        end
      end

    end

    register :jaguar, Jaguar
  end
end
