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

    def each_capitalized
      return enum_for(__method__) {@headers.size } unless block_given?
      @headers.each do |k,v|
        yield capitalize(k), String(v)
      end
    end

    def to_hash ; @headers ; end

    private

    def capitalize(name)
      name.to_s.split(/-/).map {|s| s.capitalize }.join('-')
    end
  end
end
