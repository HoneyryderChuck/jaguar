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
        ctx = OpenSSL::SSL::SSLContext.new
        ctx.cert = OpenSSL::X509::Certificate.new(@options[:ssl_cert])
        ctx.key  = OpenSSL::PKey::RSA.new(@options[:ssl_key])

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

        server = TCPServer.new(@uri.host, @uri.port)
        OpenSSL::SSL::SSLServer.new(server, ctx)
      when "unix"
        UNIXServer.new(@uri.host)
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
