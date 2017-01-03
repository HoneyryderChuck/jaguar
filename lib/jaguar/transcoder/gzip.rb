module Jaguar::Transcoder
  class GZIP
    def self.encode(**args)
      encoder = new(**args)
      begin
        yield encoder
      ensure
        encoder.close
      end
    end

    def initialize(mtime: Time.now)
      @gzip = ::Zlib::GzipWriter.new(self)
      @gzip.mtime = mtime
    end 
 
    def encode(body, &blk)
      body.each do |chunk|
        @callback = blk
        @gzip.write(chunk)
        @gzip.flush
      end
    end

    def close
      @gzip.close
      @callback = nil
    end

    def write(chunk)
      @callback.call(chunk)
    end

  end
end
