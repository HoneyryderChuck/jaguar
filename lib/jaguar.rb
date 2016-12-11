require "jaguar/version"

require "time"
require "base64"
require "io/wait"
require "openssl"
require "webrick/httpstatus"
# this might be temporarily here. let's see how 
# https://bugs.ruby-lang.org/issues/12935 turns out


require "celluloid/current"
require "celluloid/io"
require "http/parser"
require "http/2"


require "jaguar/config"

require "jaguar/container"
require "jaguar/reactor"
require "jaguar/server"

require "jaguar/http/headers"
require "jaguar/http/response"

require "jaguar/http1/headers"
require "jaguar/http1/handler"
require "jaguar/http1/request"
require "jaguar/http1/response"

require "jaguar/http2/headers"
require "jaguar/http2/handler"
require "jaguar/http2/request"
require "jaguar/http2/response"
require "jaguar/http2/promise"
