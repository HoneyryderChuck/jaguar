require_relative "../test_container"

class Jaguar::HTTP1::HTTPServerTest < ContainerTest
  include Requests::UnsupportedVersions

  include Requests::PlainGet
  include Requests::EncodingGet
  include Requests::ChunkedGet
  include Requests::KeepAliveGet
  include Requests::UpgradeGet
  include Requests::StreamGet

  include Requests::PlainPost
  include Requests::DecodingPost
  include Requests::MultipartPost

  private
 
  def client
    @client ||= begin
      uri = URI(server_uri)
      conn = Net::HTTP.new(uri.host, uri.port)
      conn.open_timeout= 1
      conn.read_timeout= 1
      Jaguar::HTTP1::Client.new(conn)
    end
  end

end
