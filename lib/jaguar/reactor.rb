module Jaguar
  class Reactor 
    include Celluloid::IO
    finalizer :stop

    def initialize(proxy, **options)
      @options = options
      @server = Socket.try_convert(proxy)
      @debug_output = @options[:debug_output] ? $stderr : nil
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
           OpenSSL::SSL::SSLError => e
      LOG { e.message }
      LOG { e.backtrace.join("\n") }
      sock.close
    end

    def is_http1?(data)
      data.match(/\A\w+ .* HTTP\/1\./)
    end

    def handle_http1(sock, action, initial: nil)
      HTTP1::Handler.new(sock, initial: initial) do |req, res|
        action.call(req, res)
        res.flush(sock)
        LOG { "HTTP1 #{req.url} -> #{res.status}" }
        sock.close # TODO: keep-alive
      end
    end

    def handle_http2(sock, action, initial: nil, upgrade: nil)
      HTTP2::Handler.new(sock, initial: initial, upgrade: upgrade) do |req, res|
        action.call(req, res)
        LOG { "HTTP2 #{req.url} -> #{res.status}" }
      end
    end


    def LOG(&msg)
      return unless $JAGUAR_DEBUG 
      $stderr << "reactor: " + msg.call + "\n"
    end
  end
end

