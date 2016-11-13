require_relative "../test_container"

class Jaguar::HTTP1::HTTPServerTest < ContainerTest

  include Requests::PlainGet


  private
 
  def client
    @client ||= begin
      uri = URI(server_uri)
      conn = Net::HTTP.new(uri.host, uri.port)
      Jaguar::HTTP1::Client.new(conn)
    end
  end

end
