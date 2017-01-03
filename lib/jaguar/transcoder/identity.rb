module Jaguar::Transcoder
  class Identity
    def self.encode(**args)
      yield new
    end

    def encode(body)
      body.each do |chunk|
        yield chunk
      end
    end
  end
end
