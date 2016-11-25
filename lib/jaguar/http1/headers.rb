module Jaguar::HTTP1
  class Headers
    def initialize(h=nil)
      @headers = {}
      return unless h
      h.each do |k, v|
        @headers[k.downcase] = Array(String(v))
      end
    end
  
    def [](key)
      a = @headers[key.downcase] or return
      a.join(",")
    end
  
    def []=(k, v)
      return unless v
      @headers[k.downcase] = [String(v)]
    end

    def add_field(k, v)
      (@headers[k.downcase] ||= []) << String(v)
    end
  
    def each
      return enum_for(__method__) {@headers.size } unless block_given?
      @headers.each do |k, v|
        yield k, v.join(", ")
      end
    end

    def each_capitalized
      return enum_for(__method__) {@headers.size } unless block_given?
      @headers.each do |k, v|
        yield capitalize(k), v.join(", ") 
      end
    end

    def to_hash ; Hash[Array(each)] ; end

    private

    def capitalize(name)
      name.to_s.split(/-/).map {|s| s.capitalize }.join('-')
    end
  end
end
