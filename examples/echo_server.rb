require 'jaguar'

Response = Struct.new(:status, :headers, :body)

APP = ->(req) do
  puts "#{req.method} request"
  puts "headers:"
  puts req.headers
  puts "body;"
  puts req.body.to_a
  body = "echo!!!!!!"
  Response.new(200, {}, [body])
end

server = Jaguar::Server.new("localhost", 9292, action: APP)

puts "server is on..."
server.run


