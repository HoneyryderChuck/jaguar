module Jaguar
  class CLI
    DEFAULTOPTIONS={
      port: 9002,
      host: "localhost"
    }

    def initialize(argv = ARGV)
      @options = DEFAULT_OPTIONS.merge(setup_options(argv))
      @action = begin
        blk = File.read(argv.last)
        action = eval "->(req, rep) {\n" + blk + "\n}"
        action
      end
    end

    def run
      uri = @options.delete(:uri)
      container = Container.new(uri, @options)
      container.run(&@action)
    end

    def setup_options(argv)
      OptionParser.new do |o|
        o.on "-u", 
             "--uri URI", 
             "uri to bind to (http://127.0.0.1, unix://0.0.0.0, https://cookiemonster.com:8080)" do |uri|
          @options[:uri] = uri
        end
    
        o.on "--debug", "activate server debugging mode" do
          @options[:log_level] = Logger::DEBUG
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
    end
  end
end