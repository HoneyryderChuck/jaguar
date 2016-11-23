module Jaguar::HTTP2
  class Response
    attr_accessor :status, :headers, :body


    def initialize(status: 200, headers: Headers.new, body: nil)
      @status = status
      @headers = headers 
      @body = nil 
    end

    def push(path, promise)
      (@promises ||= []) << [path, promise]
    end

    def flush(stream)
      headers = @headers.to_hash
      stream.headers({":status" => @status.to_s}.merge(headers), end_stream: false)
      if @promises
        push_streams = []
        @promises.map do |path, promise|
          promise_headers = promise.headers
          head = {
            ":method"    => "GET",
            ":authority"  => headers["referer"] || "", 
            ":scheme"     => headers[":scheme"] || "https", 
            ":path"       => path }
          stream.promise(head) do |push_stream|
            push_stream.headers({":status" => String(promise.status)}.merge(promise_headers))
            push_streams << push_stream
          end
        end
      end
      @body.each do |chunk|
        stream.data(chunk, end_stream: false)
      end if @body
      stream.data("")
      @promises.each_with_index.map do |(_, promise), i|
        push_stream = push_streams[i]
        promise.body.each do |chunk|
          push_stream.data(chunk, end_stream: false)
        end if promise.body
        push_stream.data("")
      end if @promises
    end

    private

    def reason
      WEBrick::HTTPStatus::StatusMessage[@status]
    end
  end
end
