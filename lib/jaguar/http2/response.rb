module Jaguar::HTTP2
  class Response
    attr_accessor :status, :headers, :body

    INITIALBODY=[]

    def initialize
      @status = 200
      @headers = Headers.new
      @body = INITIALBODY
    end

    def flush(stream)
      stream.headers({":status" => @status.to_s}.merge(@headers), end_stream: false)
      @body.each do |chunk|
        stream.data(chunk, end_stream: false)
        stream.data("")
      end
    end

    private

    def reason
      WEBrick::HTTPStatus::StatusMessage[@status]
    end
  end
end
