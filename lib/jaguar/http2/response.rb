module Jaguar::HTTP2
  class Response
    def initialize(proxyres, stream)
      @proxy = proxyres
      @stream = stream
    end

    def status
      @proxy.status
    end

    def headers
      {":status" => status.to_s}.merge(@proxy.headers)
    end

    def flush
      @stream.headers(headers, end_stream: false)
      @proxy.body.each do |chunk|
        @stream.data(chunk, end_stream: false)
        @stream.data("\0")
      end
    end

  end
end
