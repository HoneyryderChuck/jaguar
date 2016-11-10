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

uri = "http://localhost:9292"
container = Jaguar::Container.new(uri)
puts "server is on..."
container.run(&APP)


