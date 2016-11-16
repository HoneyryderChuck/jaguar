module Jaguar::HTTP1
  class Headers
    def initialize(h=nil)
      @headers = {}
      return unless h
      h.each do |k, v|
        @headers[k.downcase] = v
      end
    end
  
    def [](key)
      @headers[key.downcase]
    end
  
    def []=(k, v)
      @headers[k.downcase] = String(v)
    end
  
    def each(&act)
      @headers.each(&act)
    end
  
    def to_hash ; @headers ; end
  end
end
