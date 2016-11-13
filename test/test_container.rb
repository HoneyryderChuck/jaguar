require_relative "test_helper"

class ContainerTest < Minitest::Test
  private
  def setup
    Celluloid.init
  end

  def teardown
    @server.stop if defined?(@server)
    @client.close if defined?(@client)
  end

  def app
    @app ||= Jaguar::Container.new(server_uri)
  end

  def server
    @server ||= app.send(:build_server)
  end

  def server_uri
    "http://127.0.0.1:8989"
  end

end
