module Jaguar::HTTP1
  class Headers < Jaguar::HTTP::Headers

    def each_capitalized
      return enum_for(__method__) {@headers.size } unless block_given?
      each do |k, v|
        yield capitalize(k), v
      end
    end

    def add_header(k, v)
      super(k, capitalize(v))
    end

    private

    def capitalize(name)
      name.to_s.split(/-/).map {|s| s.capitalize }.join('-')
    end

  end
end
