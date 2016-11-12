gem "minitest"
require "minitest/autorun"

require "jaguar"
require "jaguar/testing/http2_client"
require "jaguar/testing/http1_client"

require "celluloid/probe"
$CELLULOID_MONITORING = false
Celluloid.shutdown_timeout = 1




