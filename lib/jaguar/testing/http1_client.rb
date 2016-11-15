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
 
    def request(verb, path, headers: {})
      request = case verb 
      when :get then Net::HTTP::Get.new(URI(path))
      end
      headers.each do |k, v|
        conv = /[A-Z]/.match(k[0]) ? k : k.capitalize
        request[conv] = v
      end
      response = @conn.request(request)
      Response.new(status: response.code.to_i,
                   headers: response.to_hash,
                   body: response.body)
    end
  end
end
