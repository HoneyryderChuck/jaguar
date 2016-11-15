module Jaguar::HTTP1
  class Headers
    def initialize(h={})
      @headers = h
    end
  
    def [](v)
      @headers[v]
    end
  
    def []=(k, v)
      @headers[k] = String(v)
    end
  
    def each(&act)
      @headers.each(&act)
    end
  
    def to_hash ; @headers ; end
  end
end
