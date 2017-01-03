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

      # rework content-length/transfer-encoding
      # Determine the message length (RFC2616 -- 4.4 Message Length)
      # 4.4.1
      if @status == 304 || @status == 204 || WEBrick::HTTPStatus::info?(@status)
        @headers.delete('content-length')
        @body.clear unless @body.empty?

      else
        encoding, @encoder = Jaguar::Transcoder.choose(request.headers["accept-encoding"])
        unless encoding.nil? or encoding == "identity"
          @headers.delete("content-length")
          @headers.add("transfer-encoding", encoding)
        end

        unless @headers.get("vary").include?("*")
          @headers.add_header("vary", "accept-encoding")
        end
      end
    end

    private

    def encode(&action)
      return enum_for(__method__) unless block_given?
      if @encoder
        mtime = @headers["last-modified"] ?
                Time.httpdate(@headers["last-modified"]) : 
                Time.now
        @encoder.encode(mtime: mtime) do |encoder|
          encoder.encode(@body) do |encoded|
            action.call(encoded)
          end
        end
      else
        @body.each(&action)
      end
    end

    def reason
      WEBrick::HTTPStatus::StatusMessage[@status]
    end

    def LOG(&msg)
      return unless $JAGUAR_DEBUG
      $stderr << "server response: " + msg.call.inspect + "\n"
    end

  end
end
  
