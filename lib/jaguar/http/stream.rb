module Jaguar::HTTP
  module Stream
    class Reader
      BLOCK_SIZE = 1024 * 16

      def initialize(reader)
        @reader = reader
        @read_buffer = String.new
        @read_buffer.force_encoding(Encoding::ASCII_8BIT)
      end

      def close
        @reader.close
      end

      def each
        return enum_for(__method__) unless block_given?
        while line = gets
          yield line
        end
      rescue Errno::EPIPE
        close
      end

      private

      def gets(eol=/\n{1,2}/, limit=nil)
        idx = @read_buffer.index(eol)

        until @eof
          break if idx
          fill_rbuff
          idx = @read_buffer.index(eol)
        end

        if eol.is_a?(Regexp)
          size = idx ? idx+$&.size : nil
        else
          size = idx ? idx+eol.size : nil
        end

        if limit and limit >= 0
          size = [size, limit].min
        end

        consume_rbuff(size)
      end

      def consume_rbuff(size=nil)
        if @read_buffer.empty?
          nil
        else
          size = @read_buffer.size unless size
          ret = @read_buffer[0, size]
          @read_buffer[0, size] = ""
          ret
        end
      end

      def fill_rbuff
        buffer = String.new
        buffer.force_encoding(Encoding::ASCII_8BIT)
        begin
          @read_buffer << rbuff(BLOCK_SIZE, buffer)
          buffer.clear
        rescue Errno::EAGAIN
          retry
        rescue EOFError
          @eof = true
        end
      end

      def rbuff(length = nil, buffer)
        begin
          @reader.read_nonblock(length, buffer)
        rescue ::IO::WaitReadable
          ::Celluloid::IO.wait_readable(@reader)
          retry
        end
        buffer
      end
      
    end

    class Writer
      def initialize(writer)
        @writer = writer
      end

      def close
        @writer.close
      end

      %w(id retry event).each do |meth|
        define_method "emit_#{meth}" do |data|
          @writer << "#{meth}: #{data}\n"
        end
      end

      def emit_data(message, eol=true)
        term =  eol ? "\n\n": "\n"
        @writer << "data: #{message.gsub(/\n|\r/,'')}#{term}"
      end
    end
  end
end
