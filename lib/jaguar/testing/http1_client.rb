module Jaguar::HTTP1
  class Client
  
    attr_reader :response, :conn
    def initialize(conn)
      @conn = conn
      @conn.start
    end

    def close
      @conn.send :do_finish
    end 
 
    def request(verb, path, version: nil, headers: {}, body: nil)
      # disable accept encoding unless specified
      request = case verb 
      when :get  then Net::HTTP::Get.new(URI(path))
      when :post then Net::HTTP::Post.new(URI(path))
      end
      request["accept-encoding"]= "identity;q=1.0"
      headers.each do |k, v|
        conv = /[A-Z]/.match(k[0]) ? k : k.capitalize
        request[conv] = v
      end
      request.body = body if body
      if version
        # hail monkey-patch
        @conn.instance_variable_set(:@curr_http_version, version)
      end
      response = @conn.request(request)
      Response.new(status: response.code.to_i,
                   headers: response.to_hash,
                   body: response.body)
    end
  end
end
