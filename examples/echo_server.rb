require 'jaguar'

Response = Struct.new(:status, :headers, :body)

APP = ->(req) do
  body = "echo!!!!!!"
  headers = {"content-type" => "text/plain", "content-length" => body.bytesize.to_s}
  Response.new(200, headers, [body])
end

server = Jaguar::Server.new("localhost", 9292, action: APP)

puts "server is on..."
server.run


