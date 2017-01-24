require_relative "../test_container"

class Jaguar::HTTP2::HTTPServerTest < ContainerTest

  include Requests::PlainGet
  include Requests::PushGet
  include Requests::EncodingGet
  include Requests::StreamGet

  include Requests::PlainPost
  include Requests::DecodingPost
  include Requests::MultipartPost

  private

  def client
    @client ||= begin
      uri = URI(server_uri)
      sock = TCPSocket.new(uri.host, uri.port)
      Jaguar::HTTP2::Client.new(sock)
    end
  end

end

