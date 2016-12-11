module Jaguar
  class HTTP2::Headers < Jaguar::HTTP::Headers
    def initialize(h={})
      convert_hash = Hash[
        h.map do |k, v|
          [convert_key(k), v]
        end 
      ]
      super(convert_hash)
    end

    private

    def convert_key(key)
      conv = key.to_s.downcase
      conv.tr! "_", "-"
      conv
    end
  end
end
