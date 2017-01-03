require_relative "test_helper"

class ContainerControlsTest < Minitest::Test

  def test_term
    assert app.state == :running, "initial container state unexpected"
    app.send_signal("TERM")
    sleep(0.1)
    assert app.state == :stopping, "final container state unexpected"
  end

  private

  def setup
    Celluloid.boot
    app.singleton_class.send(:include, SignalHelpers)
    @thread = Thread.start do
      app.run do |req, rep|
        rep.body = "Bang"
      end
    end
    sleep 0.1 until app.state == :running
  end

  def teardown
    Celluloid.shutdown
    @thread.kill
  end

  def app
    @app ||= Jaguar::Container.new(server_uri)
  end

  def server_uri
    "http://localhost:8989"
  end


  module SignalHelpers
    def send_signal(sig)
      @__w__.puts(sig)
    end
  end
end
