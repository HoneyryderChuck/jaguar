require 'jaguar'

APP = ->(req, res) do
  body = "echo!!!!!!"
  res.status = 200
  res.headers["content-type"] = "text/plain"
  res.headers["content-length"] = body.bytesize.to_s 
  res.body = [body]
end

uri = "https://localhost:9292"
cert = File.read("test/support/ssl/server.crt")
key  = File.read("test/support/ssl/server.key")
container = Jaguar::Container.new(uri, ssl_cert: cert, ssl_key: key)
puts "server is on..."
container.run(&APP)


