require "zlib"
module Jaguar
  module Transcoder

    PREFERRED = %w(gzip deflate identity).freeze

    def self.preferred
      @preferred ||= []
    end

    def self.preferred=(encodings)
      @preferred = Array(encodings)
    end

    def self.handlers
      @handlers ||= {}
    end

    def self.register(encoding, handler)
      handlers[encoding] = handler
      preferred << encoding
    end

    def self.choose(encodings)
      encoding = select(preferred, encodings) || "identity"
      encoder  = handlers[encoding] ||
        raise("#{encoding}: unsupported encoding")
      [encoding, encoder]
    end

    def self.select(available_encodings, accept_encoding)
      return unless accept_encoding
      # http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html
      has_identity = false
      encodings = {}

      encodings = accept_encoding.split(/\s*,\s*/).each_with_object({}) do |part, mem|
        attribute, parameters = part.split(/\s*;\s*/, 2)
        quality = 1.0
        if parameters 
          q = parameters[/\Aq=([\d.]+)/, 1]
          quality = q.to_f if q
        end
        if quality == 0.0
          has_identity ||= (attribute == "*" || attribute == "identity")
          next
        end
        if attribute == "*"
          available_encodings.each do |enc|
            mem[enc] = quality
            has_identity ||= enc == "identity" 
          end
        else
          mem[attribute] = quality
          has_identity ||= attribute == "identity" 
        end
      end

      encoding_candidates = encodings.sort_by { |_, q| -q }.map { |m, _| m }

      encoding_candidates.push("identity") unless has_identity

      return (encoding_candidates & available_encodings)[0]
    end

    require "jaguar/transcoder/identity"
    require "jaguar/transcoder/gzip"
    require "jaguar/transcoder/deflate"

    register "gzip",     GZIP
    register "deflate",  Deflate
    register "identity", Identity
  end
end
