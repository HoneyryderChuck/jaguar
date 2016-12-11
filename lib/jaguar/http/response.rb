module Jaguar::HTTP
  class Response
    attr_accessor :status, :body
    attr_reader :headers

    def initialize(status: 200, headers: Headers.new, body: [])
      @status = status
      @headers = headers 
      @body = Array(body)
    end

    def pre_process(request)

    end

    def post_process(request)
      @headers["server"] ||= "Jaguar/#{Jaguar::VERSION} (Ruby/#{RUBY_VERSION}/#{RUBY_RELEASE_DATE}"
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
  
