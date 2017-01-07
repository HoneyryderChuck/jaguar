
module Jaguar::HTTP1
  CRLF = "\r\n"
  class Response < Jaguar::HTTP::Response

    def initialize(status: 200, headers: Headers.new, body: [])
      super
    end

    def flush(sock)
      write(sock, "HTTP/1.1 #{@status} #{reason}#{CRLF}")
      @headers.each_capitalized do |k, v|
        write(sock, "#{k}: #{v}#{CRLF}")
      end
      write(sock, CRLF)

      encode.each do |chunk| 
        write_body(sock, chunk)
      end
    end

    def post_process(request)
      super

      # handle keep alive
      @headers["connection"] ||= begin
        if (conn = request.headers["connection"]) &&
           /keep-alive/io =~ conn
          "keep-alive"
        else
          "close"
        end
      end


      # rework content-length/transfer-encoding
      # Determine the message length (RFC2616 -- 4.4 Message Length)
      # 4.4.2
      if @headers.get("transfer-encoding").include?("chunked")
        # this assumes previous layer already encoded
        @headers.delete("content-length")
      # 4.4.4
      elsif @headers.get("content-type").include?("multipart/byteranges")
        @headers.delete("content-length")
      # 4.4.5
      elsif @headers.get("content-length").empty?
        # this should never happen, as responses should come with the
        # header already filled in.
        @headers.add("transfer-encoding", "chunked") unless @stream
      end

    end

    private

    def encode(&action)
      if @headers.get("transfer-encoding").include?("chunked")
        Chunker.new(super(&action))
      else
        super(&action)
      end
    end

    def write(sock, payload)
      sock.write(payload)
      LOG { payload }
    end
 
    def write_body(sock, payload)
      write(sock, payload) if payload.bytesize > 0
    end

  end
end
