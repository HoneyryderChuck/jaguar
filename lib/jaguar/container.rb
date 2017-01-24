require "uri"

module Jaguar
  class Container

    attr_reader :state

    def initialize(uri, **options)
      @uri = uri.is_a?(URI::Generic) ? uri : URI.parse(uri)
      @options = options
      @__r__, @__w__ = IO.pipe
      @state = :idle
    end


    def run(&action)
      # only idle containers are runnable
      return unless @state == :idle

      @state = :booting
      set_signal_handlers

      server = build_server

      server.run(&action)

      @state = :running
      while @__r__.wait_readable
        signal = @__r__.gets.strip
        handle_signal(signal)
      end
    rescue Interrupt
      @state = :stopping
      LOG { "Jaguar was put to sleep..." }
      server.stop if server
      @state = :idle
    end

    private

    def build_server(options={})
      options = @options.merge(options)
      sock_server = case @uri.scheme
      when "http", "https"
        server = TCPServer.new(@uri.host, @uri.port)
        server.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
        server.setsockopt(Socket::SOL_SOCKET,Socket::SO_REUSEADDR, true)
        
        if @uri.scheme == "https"
          raise "must pass ssl certificate" unless options[:ssl_cert]
          raise "must pass ssl key" unless options[:ssl_key]
 
          ctx = OpenSSL::SSL::SSLContext.new
          ctx.cert = OpenSSL::X509::Certificate.new(options.delete(:ssl_cert))
          ctx.key  = OpenSSL::PKey::RSA.new(options.delete(:ssl_key))


          if http2?
            ctx.ssl_version = :TLSv1_2
            ctx.options = OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:options]
            ctx.ciphers = OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ciphers]
            ctx.alpn_protocols = %w(h2)
  
            ctx.alpn_select_cb = proc do |protocols|
              raise "Protocol h2 is required" if protocols.index("h2").nil?
              "h2"
            end
      
            ctx.tmp_ecdh_callback = proc do |*_args|
              OpenSSL::PKey::EC.new "prime256v1"
            end
          end

          server = OpenSSL::SSL::SSLServer.new(server, ctx)
        end
        server
      when "unix" # TODO: support for unix socket over ssl????
        UNIXServer.new(@uri.host)
      else
        raise "unsupported scheme type for uri (#{@uri.to_s})"
      end
      sock_server.listen(1024)
      Server.new(sock_server, options)
    end

    def handle_signal(signal)
      LOG { "received signal: #{signal}" }
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

    def http2?
      protocols = @options[:protocols]
      !protocols || protocols.include?("http2")
    end

    def LOG(&msg)
      return unless $JAGUAR_DEBUG 
      $stderr << msg.call + "\n"
    end
  end
end
