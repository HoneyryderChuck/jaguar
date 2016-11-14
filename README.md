# jaguar

yet another http server, with a twist.

## Features

* HTTP2 server
* HTTP1.1 server
* HTTP1.1 and HTTP2 over ssl (HTTP2 must be ruby 2.3 or higher)
* RepRep Interface (aka `#call(req,rep)`)
* Fallback Rack-Compatible Interface (aka `#call(env)`) (not HTTP2-compatible)

## TODO

* Plain-text HTTP1-to-2 connection upgrade
* Provide worker pool abstraction
  * Pool Worker
  * Threaded Worker
  * Hybrid/Cluster Worker
  * In-thread reactor-friendly worker
* Multi-app server support

## Examples

* `bundle exec ruby examples/echo_server.rb`
* `bundle exec bin/jaguar -u https://localhost:9292 --ssl-cert test/support/ssl/server.crt --ssl-key test/support/ssl/server.key examples/echo.rb`
