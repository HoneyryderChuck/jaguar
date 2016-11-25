require_relative "test_helper"

class ContainerTest < Minitest::Test
  private
  def setup
    Celluloid.boot
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
