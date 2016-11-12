require_relative "http_server_test"

class Jaguar::HTTP1::SSLServerTest < Jaguar::HTTP1::HTTPServerTest
  private

  def setup
    Celluloid.init
    @app = Jaguar::Container.new(server_uri, ssl_cert: File.read("test/support/ssl/server.crt"),
                                             ssl_key:  File.read("test/support/ssl/server.key"))
  end

  def server_uri
    "https://127.0.0.1:8990"
  end

  def http_client
    uri = URI(server_uri)
    conn = Net::HTTP.new(uri.host, uri.port)
    conn.use_ssl = true
    conn.verify_mode = OpenSSL::SSL::VERIFY_NONE
    Jaguar::HTTP1::Client.new(conn)
  end
end
