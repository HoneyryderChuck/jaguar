module Jaguar::Transcoder
  class Identity
    def self.encode(**args)
      yield new
    end

    def encode(chunk)
      yield chunk
    end
  end
end
