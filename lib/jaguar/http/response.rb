module Jaguar::HTTP
  class Response
    attr_accessor :status, :body
    attr_reader :headers

    def initialize(status: 200, headers: Headers.new, body: [])
      @status = status.to_i
      @headers = headers 
      @body = Array(body)
    end

    def pre_process(request)

    end

    def post_process(request)
      # set default headers (adapted from webrick http response)
      @headers["server"] ||= "Jaguar/#{Jaguar::VERSION} (Ruby/#{RUBY_VERSION}/#{RUBY_RELEASE_DATE}"
      @headers["date"] ||= Time.now.httpdate

    end

    private

    def reason
      WEBrick::HTTPStatus::StatusMessage[@status]
    end

    def LOG(&msg)
      return unless $JAGUAR_DEBUG
      $stderr << "server response: " + msg.call.inspect + "\n"
    end

  end
end
  
