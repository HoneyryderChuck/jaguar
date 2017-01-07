require_relative "http_server_test"

class Jaguar::HTTP2::SSLServerTest < ContainerTest
  include Requests::PlainGet 
  include Requests::PushGet 
  include Requests::EncodingGet
  include Requests::StreamGet

  include Requests::PlainPost

  private
  def app
    @app ||= Jaguar::Container.new(server_uri, ssl_cert: File.read("test/support/ssl/server.crt"),
                                               ssl_key:  File.read("test/support/ssl/server.key"))
  end

  def server_uri
    "https://127.0.0.1:8990"
  end

  def client
    @client ||= begin
      uri = URI(server_uri)
      sock = TCPSocket.new(uri.host, uri.port)

      ctx = OpenSSL::SSL::SSLContext.new
      ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE

      ctx.npn_protocols = %w(h2)

      ctx.npn_select_cb = lambda do |protocols|
        "h2" if protocols.include?("h2")
      end

      sock = OpenSSL::SSL::SSLSocket.new(sock, ctx)
      sock.sync_close = true
      sock.hostname = uri.hostname
      sock.connect

      Jaguar::HTTP2::Client.new(sock)
    end
  end
end
