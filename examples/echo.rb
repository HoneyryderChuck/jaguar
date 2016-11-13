body = "echo!!!!!!"
headers = {"content-type" => "text/plain", "content-length" => body.bytesize.to_s}
rep.status = 200
rep.headers["content-type"] = "text/plain"
rep.headers["content-length"] = body.bytesize.to_s 
rep.body = [body]
