gem "minitest"
require "minitest/autorun"

require "jaguar"
require "jaguar/testing/http2_client"
require "jaguar/testing/http1_client"

require "celluloid/probe"
$CELLULOID_MONITORING = false
#$JAGUAR_DEBUG = true
Celluloid.shutdown_timeout = 1

Dir[File.join(".", "test", "support", "**", "*.rb")].each { |f| require f }

