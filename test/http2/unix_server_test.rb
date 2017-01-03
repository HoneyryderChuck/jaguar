require_relative "http_server_test"
require "tempfile"

class Jaguar::HTTP2::UnixServerTest < ContainerTest 
  include Requests::PlainGet
  include Requests::PushGet

  include Requests::PlainPost

  private
  def setup
    super
    @sockpath = "jagtest.sock"
  end

  def app
    @app ||= Jaguar::Container.new("unix://#{@sockpath}")
  end

  def teardown
    super
    File.unlink(@sockpath) rescue nil
  end


  def client
    @client ||= begin
      sock = UNIXSocket.new(@sockpath)
      Jaguar::HTTP2::Client.new(sock)
    end
  end
end
