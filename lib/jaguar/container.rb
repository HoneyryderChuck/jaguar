module Jaguar
  class Container
    def initialize
      @__r__, @__w__ = IO.pipe
    end


    def run
      set_signal_handlers


      while @__r__.wait_readable
        signal = @__r__.gets.strip
        handle_signal(signal)
      end
    rescue Interrupt
      STDOUT.puts "Jaguar was put to sleep..."
      exit(0)
    end


    private

    def handle_signal(signal)
      case signal
      when "INT", "TERM"
        raise Interrupt
      end
    end

    def set_signal_handlers

      %w(INT TERM).each do |signal|
        begin
          trap signal do
            @__w__.puts(signal)
          end
        rescue ArgumentError
          STDERR.puts "#{signal}: signal not supported"
        end
      end
  end
end
