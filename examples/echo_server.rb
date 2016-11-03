require 'jaguar'

Response = Struct.new(:status, :headers, :body)

APP = ->(req, res) do
  body = "echo!!!!!!"
  headers = {"content-type" => "text/plain", "content-length" => body.bytesize.to_s}
  res.status = 200
  res.headers["content-type"] = "text/plain"
  res.headers["content-length"] = body.bytesize.to_s 
  res.body = [body]
end

tcp_server = TCPServer.new("localhost", 9292)
server = Jaguar::Server.new(tcp_server, action: APP)

puts "server is on..."
server.run


