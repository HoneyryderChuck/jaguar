module Jaguar
  class CLI
    DEFAULTOPTIONS={
      port: 9002,
      host: "localhost"
    }

    def initialize(argv = ARGV)
      @options = DEAULT_OPTIONS.merge(setup_options(argv))
    end

    def run

    end

    def setup_options(argv)
      OptionParser.new do |o|
        o.on "-b", 
             "--bind HOST", 
             "host to bind to (127.0.0.1, 0.0.0.0, cookiemonster.com)" do |host|
          @options[:host] = host
        end

        o.on "-p", 
             "--port PORT", Integer, 
             "port to bind to" do |port|
          @options[:port] = port
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
