module Jaguar::Transcoder
  class Deflate
    def self.encode(**args)
      encoder = new(**args)
      begin
        yield encoder
      ensure
        encoder.close
      end
    end

    def initialize(**)
      @deflater = ::Zlib::Deflate.new(Zlib::DEFAULT_COMPRESSION,
                                      # drop the zlib header which causes both Safari and IE to choke
                                      -Zlib::MAX_WBITS,
                                      Zlib::DEF_MEM_LEVEL,
                                      Zlib::DEFAULT_STRATEGY)
    end 
 
    def encode(body)
      body.each do |chunk|
        yield @deflater.deflate(chunk, Zlib::SYNC_FLUSH)
      end
      @last_block = @deflater.finish
      yield @last_block
    end

    def close
      @deflater.finish unless @last_block
      @deflater.close
      @last_block = nil
    end
  end
end

