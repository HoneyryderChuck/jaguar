require "jaguar"
require "json"
require "pathname"

TEXT = <<-OUT
As armas e os barões assinalados,
Que da ocidental praia Lusitana,
Por mares nunca de antes navegados,
Passaram ainda além da Taprobana,
Em perigos e guerras esforçados,
Mais do que prometia a força humana,
E entre gente remota edificaram
Novo Reino, que tanto sublimaram!
OUT

ROOT = Pathname.new(File.expand_path(File.dirname(__FILE__))).join("streaming")
expander = ->(f) { f.file? ? f : f.children.flat_map(&expander) }
FILES = ROOT.children.flat_map(&expander)

APP = ->(req, res) do
  if req.url == "/index.html"
    path = ROOT.join(req.url[1..-1]) # trailing "/"
    file = ROOT.join(path) # trailing "/"
    body = file.read
    res.headers["content-type"] = "text/html"
    res.headers["content-length"] = body.bytesize.to_s
    res.body = [body] 
  elsif req.url == "/activity"
    str = res.stream!
    TEXT.each_line do |line|
      str.emit_data(JSON.dump({codes: [], text: line}))
    end
  else
    body = "Not Found!"
    res.status = 404
    res.headers["content-type"] = "text/plain"
    res.headers["content-length"] = body.bytesize
    res.body = [body]
  end
end

config = Jaguar::Config.load do
  bind "https://localhost:9292"
  ssl_cert File.read("test/support/ssl/server.crt")
  ssl_key  File.read("test/support/ssl/server.key")
end
#container = Jaguar::Container.new(uri, ssl_cert: cert, ssl_key: key)
container = Jaguar::Container.new(config.uri, config.options)
puts "server is on..."
container.run(&APP)
