require "uri"

module Jaguar
  class Container
    def initialize(uri, **options)
      @uri = URI.parse(uri)
      @options = options
      @__r__, @__w__ = IO.pipe
    end


    def run(&action)
      set_signal_handlers

      server = build_server

      server.run(&action)

      while @__r__.wait_readable
        signal = @__r__.gets.strip
        handle_signal(signal)
      end
    rescue Interrupt
      STDOUT.puts "Jaguar was put to sleep..."
      server.stop if server
    end

    private

    def build_server
      sock_server = case @uri.scheme
      when "http"
        TCPServer.new(@uri.host, @uri.port)
      when "https"
      when "unix"
      else
        raise "unsupported scheme type for uri (#{@uri.to_s})"
      end
      Server.new(sock_server, @options)
    end

    def handle_signal(signal)
      case signal
      when "INT", "TERM"
        raise Interrupt
      end
    end

    def set_signal_handlers

      %w(INT TERM).each do |signal|
        begin
          trap signal do
            @__w__.puts(signal)
          end
        rescue ArgumentError
          STDERR.puts "#{signal}: signal not supported"
        end
      end
    end
  end
end
