gem "minitest"
require "minitest/autorun"

require "jaguar"

require "celluloid/probe"
$CELLULOID_MONITORING = false
Celluloid.shutdown_timeout = 1

