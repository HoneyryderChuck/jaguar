require_relative "test_helper"

class ContainerTest < Minitest::Test
  include CreateCerts
  private
  def setup
    Celluloid.boot
  end

  def certs_dir
    File.join("test", "support", "certs")
  end

  def teardown
    @client.close if defined?(@client)
    @server.stop if defined?(@server)
    Celluloid.shutdown
  end

  def app
    @app ||= Jaguar::Container.new(server_uri)
  end

  def server
    @server ||= app.send(:build_server)
  end

  def server_uri
    "http://localhost:8989"
  end

end
