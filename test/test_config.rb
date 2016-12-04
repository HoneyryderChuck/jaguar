require_relative "test_helper"

class ConfigTest < Minitest::Test

  def test_bind
    config = Jaguar::Config.new
    config.bind "http://localhost"
    uri = config.url
    assert uri.host == "localhost", "unexpected host"
    assert uri.port == 80, "unexpected port"
    assert uri.scheme == "http", "unexpected scheme"
  end

  def test_load_from_block
    app = -> {}
    config = Jaguar::Config.load do |config|
      config.app(app)
    end
    assert config.app == app, "unexpected app"
  end

  def test_load_from_file
    conf = <<-OUT
app { 42 }
    OUT
    file = Tempfile.new
    file.write(conf)
    file.close

    config = Jaguar::Config.load(file.path)
    assert config.app.call == 42, "unexpected app"
  ensure
    if file
      file.unlink
    end
  end
end
