require "jaguar/http1/parser"

module Jaguar::HTTP1
  #
  # the request MUST respond to:
  # * #verb (returns a String ("GET", "POST"...)
  # * #request_url (returns a URL)
  # * #headers (returns an headers hash)
  # * #body (returns an Enumerable)
  # 
  class Request
    extend Forwardable


    def_delegators :@parser, :verb, :http_version,
                             :url
    alias_method :version, :http_version

    attr_reader :body

    def initialize(parser, body)
      @parser = parser
      @body = body
    end


    def headers
      @headers ||= Headers.new(@parser.headers)
    end
  end
end
