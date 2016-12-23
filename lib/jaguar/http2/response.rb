module Jaguar::HTTP2
  class Response < Jaguar::HTTP::Response

    def initialize(status: 200, headers: HTTP2::Headers.new, body: [])
      super
    end

    def post_process(request)
      super
      @headers["referer"] ||= request.headers[":authority"]
    end

    def enable_push!(resource_dirs)
      @promises = @headers.each_value("link").map do |link|
        resource, *props = link.split("; ")
        props = Hash[ props.map { |prop| prop.split("=") } ]
        Promise.new(resource[/<(.+)>/,1], props, resource_dirs)
      end
      # TODO: order by priority
    end

    def flush(stream)
      headers = @headers.to_hash
      stream.headers({":status" => @status.to_s}.merge(headers), end_stream: false)
      if @promises
        push_streams = []
        @promises.map do |promise|
          next if promise.props["rel"] == "nopush"
 
          promise_headers = promise.headers
          head = {
            ":method"    => "GET",
            ":authority"  => headers["referer"] || "", 
            ":scheme"     => headers[":scheme"] || "https", 
            ":path"       => promise.path }
          stream.promise(head) do |push_stream|
            push_stream.headers({":status" => "200"}.merge(promise_headers))
            push_streams << push_stream
          end
        end
      end
      encode.each do |chunk|
        stream.data(chunk, end_stream: false)
      end if @body
      stream.data("")
      @promises.each_with_index do |promise, i|
        push_stream = push_streams[i]
        promise.body.each do |chunk|
          push_stream.data(chunk, end_stream: false)
        end if promise.body
        push_stream.data("")
      end if @promises
    end


  end
end
