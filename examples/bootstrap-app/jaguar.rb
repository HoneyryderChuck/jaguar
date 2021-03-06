require "pathname"
ROOT = Pathname.new(File.expand_path(File.dirname(__FILE__)))
expander = ->(f) { f.file? ? f : f.children.flat_map(&expander) }
FILES = ROOT.children.flat_map(&expander)

puts "serving from #{ROOT}"

bind "https://localhost:9292"
ssl_cert File.read("test/support/ssl/server.crt")
ssl_key  File.read("test/support/ssl/server.key")

app do |req, res|
  file = ROOT.join(req.url[1..-1]) # trailing "/"
  if file.file? and FILES.include?(file)
    puts "serving #{req.url}..."

    ext = file.extname[1..-1] # trailing "."
    body = file.read
    # promise
    if ext.end_with?("html") and req.version >= "2"
      %w{
/css/bootstrap.min.css
/css/bootstrap-theme.min.css
/css/main.css
/js/vendor/modernizr-2.8.3-respond-1.4.2.min.js
/js/vendor/bootstrap.min.js
/js/main.js
      }.each do |path|
        puts "pushing #{path} ..."
        as = path.end_with?("css") ? "style" : "script"
        res.headers.add("Link", "<#{path}>; rel=preload; as=#{as}")
      end
    end

    res.headers["content-type"] = "text/#{ext}"
    res.headers["content-length"] = body.bytesize.to_s
    res.body = [body]
    res.enable_push!([ROOT]) if req.version >= "2"
  else
    body = "Not Found!"
    res.status = 404
    res.headers["content-type"] = "text/plain"
    res.headers["content-length"] = body.bytesize
    res.body = [body]
  end
end

