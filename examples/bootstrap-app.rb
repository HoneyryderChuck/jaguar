require "jaguar"
require "pathname"

ROOT = Pathname.new(File.dirname(__FILE__)).join("bootstrap-app")

APP = ->(req, res) do
  file = ROOT.join(req.url[1..-1]) # trailing "/"
  if file.file? or not ROOT.children.include?(file)
    ext = file.extname[1..-1] # trailing "."
    body = file.read
    res.headers["content-type"] = "text/#{ext}"
    res.headers["content-length"] = body.bytesize.to_s
    res.body = [body]
  else
    body = "Not Found!"
    res.status = 404
    res.headers["content-type"] = "text/plain"
    res.headers["content-length"] = body.bytesize.to_s
    res.body = [body]
  end
end

uri = "https://localhost:9292"
cert = File.read("test/support/ssl/server.crt")
key  = File.read("test/support/ssl/server.key")
container = Jaguar::Container.new(uri, ssl_cert: cert, ssl_key: key)
puts "server is on..."
container.run(&APP)
