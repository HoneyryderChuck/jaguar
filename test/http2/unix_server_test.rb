require_relative "http_server_test"
require "tempfile"

class Jaguar::HTTP2::UnixServerTest < Jaguar::HTTP2::HTTPServerTest
  include Requests::PlainGet

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
