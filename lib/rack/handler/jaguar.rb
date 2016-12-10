require 'rack/handler'

module Rack
  module Handler
    module Jaguar 
      DEFAULT_OPTIONS = {
        :Verbose => false,
        :Silent  => false
      }

      def self.run(app, **options)
        host = options.delete(:Host)
        port = options.delete(:Port)

        require "jaguar"

        server = ::Jaguar::Container.new("http://#{host}:#{port}", options)               

        begin
          server.run(&Wrapper.new(app).method(:call))
        rescue Interrupt
          puts "* Gracefully stopping, waiting for requests to finish"
          server.stop
          puts "* Goodbye!"
        end
      end

      # most of this was copied from the reel rack adapter
      class Wrapper

        CONTENT_LENGTH_HEADER = %r{^content-length$}i

        def initialize(rackapp)
          @app = rackapp
        end

        def call(req, rep)

          options = {
            method: req.verb,
            input:  req.body.to_s
          }.merge(convert_headers(req.headers))


          normalize_env(options)

          env = ::Rack::MockRequest.env_for(req.url, options)

          status, headers, body = @app.call(env) 

          rep.status = status
          headers.each do |k, v|
            rep.headers[k]= v
          end

          if body.respond_to? :each
            # Can't use collect here because Rack::BodyProxy/Rack::Lint isn't a real Enumerable
            body.each do |chunk|
              rep.body << chunk
            end
            rep.headers["Content-Length"] = rep.body.map(&:length).reduce(:+)
          else
            Logger.error("don't know how to render: #{body.inspect}")
            request.respond :internal_server_error, "An error occurred processing your request"
          end

          body.close if body.respond_to? :close

        end

        NO_PREFIX_HEADERS=%w[CONTENT_TYPE CONTENT_LENGTH]

        def convert_headers(headers)
          Hash[headers.to_hash.map { |key, value|
            header = key.upcase.gsub('-','_')

            if NO_PREFIX_HEADERS.member?(header)
              [header, value]
            else
              ['HTTP_' + header, value]
            end
          }]
        end


        def normalize_env(env)
          if host = env["HTTP_HOST"]
            if colon = host.index(":")
              env["SERVER_NAME"] = host[0, colon]
              env["SERVER_PORT"] = host[colon+1, host.bytesize]
            else
              env["SERVER_NAME"] = host
              env["SERVER_PORT"] = default_server_port(env)
            end
          else
            env["SERVER_NAME"] = "localhost"
            env["SERVER_PORT"] = default_server_port(env)
          end
        end
      end 
    end

    register :jaguar, Jaguar
  end
end
