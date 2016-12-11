require "jaguar"
module Jaguar
  class CLI
    DEFAULTOPTIONS={
      port: 9292,
      host: "localhost",
      protocols: %w(http1 http2)
    }

    def initialize(argv = ARGV)
      @options = DEFAULTOPTIONS
      setup_options(argv)

      @action ||= begin
        blk = File.read(argv.last)
        action = eval "->(req, rep) {\n" + blk + "\n}"
        action
      end unless argv.empty?
    end

    def run
      container = Container.new(fetch_uri, @options)
      container.run(&@action)
    end

    private

    def fetch_uri
      @options.delete(:uri) || 
      "http://#{@options[:host]}:#{@options[:port]}"
    end

    def setup_options(argv)
      OptionParser.new do |o|
        o.on "-u", 
             "--uri URI", 
             "uri to bind to (http://127.0.0.1, unix://0.0.0.0, https://cookiemonster.com:8080)" do |uri|
          @options[:uri] = uri
        end

        o.on "-c", "--config PATH", "Load PATH as a config file" do |path|
          @options[:config] = Config.load(path) 
        end

        o.on "--protocols PROTOCOLS", "colon-separated http versions supported (ex: http1:http2)" do |proto|
          @options[:protocols] = proto.split(":")
        end

        o.on "--ssl-cert PATH",
             "location in the file system of the ssl certificate to use" do |path|
          @options[:ssl_cert] = File.read(path)
        end

        o.on "--ssl-key PATH",
             "location in the file system of the ssl key to use" do |path|
          @options[:ssl_key] = File.read(path)
        end
    
        o.on "--debug", "activate server debugging mode" do
          $JAGUAR_DEBUG = true 
        end
        
    
        o.on "-I", "--include PATH", "specify paths to load" do |arg|
          $LOAD_PATH.unshift(*arg.split(':'))
        end
    
        o.on "-V", "--version", "show version" do
          puts Jaguar::VERSION
          exit 0
        end
       
        o.banner = "jaguar <options> app.rb"
    
        o.on_tail "-h", "--help", "Show help" do
          STDOUT.puts o
          exit 0
        end
      end.parse!(argv)

      if config = @options.delete(:config)
        # cli parameters take precedence over config
        @options.merge!(config.options)
        @action = config.app
      end
    end
  end
end
