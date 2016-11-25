require_relative "../test_container"
require "tempfile"

class Jaguar::HTTP1::UnixServerTest < ContainerTest 
  private
  def setup
    super
    @sockpath = "jagtest.sock"
    @app = Jaguar::Container.new("unix://#{@sockpath}")
  end

  def teardown
    File.unlink(@sockpath) rescue nil
  end


  def http_client
    sock = UNIXSocket.new(@sockpath)
    Jaguar::HTTP1::Client.new(sock)
  end
end
