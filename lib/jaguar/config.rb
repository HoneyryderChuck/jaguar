module Jaguar
  class Config
    attr_reader :url, :options
    def initialize
      @options = {}
    end

    def app(obj=nil, &action)
      @app ||= obj || action
      raise "you must set an app" unless @app and @app.respond_to?(:call)
      @app
    end

    def bind(url)
      @url = URI(url)
    end

    def debug(deb=false)
      @options[:debug] = !!deb
    end

    def ssl_cert(cert)
      @options[:ssl_cert] = cert
    end

    def ssl_key(key)
      @options[:ssl_key] = key 
    end

    def keep_alive_timeout(tim)
      raise "keep alive timeout must be a positive integer" unless tim and tim > 0
      @options[:keep_alive_timeout] = tim
    end

    def protocols(*protocols)
      @options[:protocols] = protocols.map(&:to_s)
    end


    class << self

      def load(path=nil, &blk)
        conf = new
        load_from_path(path, conf) if path
        load_from_block(blk, conf) if blk
        conf
      end

      private

      def load_from_block(block, conf)
        if block.arity == 0
          conf.instance_exec(&block)
        else
          block.call(conf)
        end
      end

      def load_from_path(path, conf)
        raise "must be a valid path" unless File.exist?(path)
        conf.instance_eval(File.read(path), path, 1)
      end
    end
  end
end
