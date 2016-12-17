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

    def delete(k)
      @headers.delete(k.downcase)
    end

    def get(k)
      @headers[k.downcase] ||= []
    end

    def add(k, v)
      (@headers[k.downcase] ||= []) << String(v)
    end
  
    def each
      return enum_for(__method__) {@headers.size } unless block_given?
      @headers.each do |k, v|
        yield k, v.join(", ") unless v.empty?
      end
    end

    def each_value(k)
      key = k.downcase
      return enum_for(__method__, k) {@headers[key].size } unless block_given?
      @headers[k].each do |v|
        yield v
      end if @headers[k]
    end

    def to_hash ; Hash[Array(each)] ; end
  end
end

