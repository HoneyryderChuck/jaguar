module Jaguar
  class Reactor 
    include Celluloid::IO

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
          handle_http2(sock, action, upgrade: request)
        end
      else
        handle_http2(sock, action, initial: data)
      end
    rescue Errno::ECONNRESET, 
           OpenSSL::SSL::SSLError => e
      LOG { e.message }
      LOG { e.backtrace }
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
      HTTP2::Handler.new(sock, initial: initial, upgrade: upgrade) do |stream|
        HTTP2::Request.new(stream) do |req|
          res = HTTP2::Response.new
          action.call(req, res)
          res.flush(stream)
          LOG { "HTTP2 #{req.url} -> #{res.status}" }
        end
        # TODO: PUSH data here
      end
    end


    def LOG(&msg)
      return unless @debug_output
      @debug_output << msg.call + "\n"
    end
  end
end

