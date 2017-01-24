require_relative "../test_container"

class Jaguar::HTTP1::SSLServerTest < ContainerTest 
  include Requests::PlainGet
  include Requests::EncodingGet
  include Requests::ChunkedGet
  include Requests::KeepAliveGet
  include Requests::StreamGet

  include Requests::PlainPost
  include Requests::MultipartPost
  private

  def setup
    super
    create_certs
  end

  def teardown
    super
    delete_certs
  end

  def app
    @app ||= Jaguar::Container.new(server_uri, ssl_cert: File.read(server_cert_path),
                                               ssl_key:  File.read(server_key_path))
  end

  def server_uri
    "https://127.0.0.1:8990"
  end

  def client
    @client ||= begin
      uri = URI(server_uri)
      conn = Net::HTTP.new(uri.host, uri.port)
      conn.use_ssl = true
      conn.ca_file = ca_cert_path
      conn.cert = OpenSSL::X509::Certificate.new(File.read(client_cert_path))
      conn.key  = OpenSSL::PKey::RSA.new(File.read(client_key_path))
 
      Jaguar::HTTP1::Client.new(conn)
    end
  end
end
