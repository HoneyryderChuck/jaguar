require_relative "http_server_test"
require "tempfile"

class Jaguar::HTTP1::UnixServerTest < ContainerTest 
  private
  def setup
    Celluloid.init
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
