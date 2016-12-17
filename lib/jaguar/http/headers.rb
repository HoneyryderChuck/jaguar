module Jaguar::HTTP
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

    def each_value(k)
      key = k.downcase
      return enum_for(__method__, k) {@headers[key].size } unless block_given?
      @headers[key].each do |v|
        yield v
      end if @headers[key]
    end

    def to_hash ; Hash[Array(each)] ; end
  end
end

