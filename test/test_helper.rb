gem "minitest"
require "minitest/autorun"

require "jaguar"
require "jaguar/testing/http2_client"
require "jaguar/testing/http1_client"

require "celluloid/probe"
$CELLULOID_MONITORING = false
Celluloid.shutdown_timeout = 1

Dir[File.join(".", "test", "support", "**", "*.rb")].each { |f| require f }



module HTTP2PossibleHeader
  def capitalize(name)
    return super unless name.start_with?("http2")

    parts = name.to_s.split(/-/)
    [parts[0].upcase, *parts[1..-1].map(&:capitalize)].join("-")
  end
end

Net::HTTPRequest.send :include, HTTP2PossibleHeader
