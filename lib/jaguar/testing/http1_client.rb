module Jaguar::HTTP1
  class Client
  
    attr_reader :response
    def initialize(conn)
      @conn = conn 
    end

    def close
      #@conn.close
    end 
 
    def request(verb, path, headers: {})
      request = case verb 
      when :get then Net::HTTP::Get.new(URI(path))
      end
      headers.each do |k, v|
        request[k.capitalize] = v
      end
      res = @conn.start do |http|
        response = http.request(request)
        Response.new(status: response.code.to_i,
                     headers: response.to_hash,
                     body: response.body)
      end
      res
    end
  
  end
end
