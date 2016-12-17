module Jaguar
  class Reactor 
    include Celluloid::IO

    KeepAliveTimeout = Class.new(Timeout::Error)
    finalizer :stop

    attr_reader :num_connections

    def initialize(proxy, **options)
      @options = options
      @server = Socket.try_convert(proxy)
      @keep_alive_timeout = options.fetch(:keep_alive_timeout, 60)
      @debug_output = @options[:debug_output] ? $stderr : nil
      @num_connections = 0
    end

    def run(action)
      loop do 
        async(:handle_connection, @server.accept, action)
      end
    rescue IOError
      LOG { "error accepting socket" }
    end


    def stop
      @server.close if !@server.closed?
    end

    private

    def handle_connection(sock, action)
      @num_connections += 1
      data = sock.readpartial(1024)
      if is_http1?(data)
        code, request = catch(:upgrade) { handle_http1(sock, action, initial: data) }
        case code
        when "h2c"
          after(0.02) do
            handle_http2(sock, action, upgrade: request)
          end
        end
      else
        handle_http2(sock, action, initial: data)
      end
    rescue Errno::ECONNRESET, IOError, 
           OpenSSL::SSL::SSLError,
           TaskTimeout,    # keep alive timeouts
           HTTP1::ConnectionError => e # use when client aborts connection 
      LOG { e.message }
      LOG { e.backtrace.join("\n") }
      sock.close
      @num_connections -= 1
    end

    def is_http1?(data)
      data.match(/\A\w+ .* HTTP\/1\./)
    end

    def handle_http1(sock, action, initial: nil)
      handler = HTTP1::Handler.new(sock, initial: initial, &action)
      while handler.handle_request(&action)
        timeout(@keep_alive_timeout) do
          sock.wait_readable
        end
      end
    end

    def handle_http2(sock, action, initial: nil, upgrade: nil)
      HTTP2::Handler.new(sock, initial: initial, upgrade: upgrade, &action)
    end

    def LOG(&msg)
      return unless $JAGUAR_DEBUG 
      $stderr << "reactor: " + msg.call + "\n"
    end
  end
end

