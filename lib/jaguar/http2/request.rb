module Jaguar::HTTP2
  #
  # the request MUST respond to:
  # * #verb (returns a String ("GET", "POST"...)
  # * #request_url (returns a URL)
  # * #headers (returns an headers hash)
  # * #body (returns an Enumerable)
  # 
  class Request

    attr_reader :headers

    def initialize(stream, &action)
      @body = String.new
      @action = action
      stream.on(:active, &method(:on_active))
      stream.on(:closed, &method(:on_close))
      stream.on(:headers, &method(:on_headers))
      stream.on(:data, &method(:on_data))
      stream.on(:half_close, &method(:on_half_close))
    end

    def body
      [@body]
    end

    def version
      "2"
    end
 
    def verb 
      @headers[":method"]
    end

    def url
      @headers[":path"]
    end

    private

    def on_active
      LOG { "stream is active!" }
    end

    def on_close
      LOG { "stream is closed" }
    end

    def on_headers(h)
      LOG { "receiving headers: #{h}" }
      @headers = HTTP2::Headers.new(Hash[h]) 
    end

    def on_data(data)
      @body << data
    end
   
    def on_half_close
      @action.call(self)
    end

    def LOG(&msg)
      return unless $JAGUAR_DEBUG 
      $stderr << "server request: " + msg.call + "\n"
    end
  end
end
