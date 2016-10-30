module Jaguar::HTTP2
  class Request

    attr_reader :headers

    def initialize(headers, data)
      @headers = headers
      @body = data
    end

    def body
      [@body]
    end

    def version

    end
 
    def method
      @headers[":method"]
    end

    def request_url
      @headers[":path"]
    end


  end
end
