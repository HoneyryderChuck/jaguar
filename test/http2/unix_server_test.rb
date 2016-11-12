require_relative "http_server_test"
require "tempfile"

class Jaguar::HTTP2::UnixServerTest < Jaguar::HTTP2::HTTPServerTest
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
    Jaguar::HTTP2::Client.new(sock)
  end
end
