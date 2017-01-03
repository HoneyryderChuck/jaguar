module Jaguar::HTTP1
  class Chunker

     def initialize(generator)
       @gen = generator
     end

     def each(&action)
       enum_for(__method__) unless block_given?

       @gen.each do |payload|
         next unless (size = payload.bytesize) > 0

         chunk = payload.dup.force_encoding(Encoding::BINARY)
 
         action.call("#{size.to_s(16)}#{CRLF}#{chunk}#{CRLF}")
       end
       action.call("0#{CRLF}#{CRLF}")
     end
    
  end
end
