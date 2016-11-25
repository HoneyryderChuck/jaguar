require "uri"
class Promise

  attr_reader :path, :props
  def initialize(path, props, resource_dirs=[])
    @props = props
    @dir = resource_dirs.find {|dir| File.exists?(File.join(dir, path)) }
    @path = path
  end

  def exists? ; @dir ; end

  def headers
    type = case @props["as"]
    when "style" then "text/css"
    when "script" then "text/javascript"
    end
    { "content-type" => type, "content-length" => payload_size.to_s }
  end

  def body
    @body ||= File.new(File.join(@dir, @path)) 
  end

  private

  def payload_size
    case body
    when File
      body.size
    else body.bytesize
    end
  end

end
