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
      LOG { to_s(debug: true) }
    end


    def headers
      @headers ||= Headers.new(@parser.headers)
    def to_s(*args)
      if args.first.respond_to?(:[]) && args.first[:debug]
        "HTTP1 #{url} #{verb}\n" +
        headers.to_hash.map { |k,v| "#{k}: #{v}" }.join("\n") +
        "\n" +
        body.to_a.join +
        "\n"
      else
        super
      end
    end
 
    private

    def LOG(&msg)
      return unless $JAGUAR_DEBUG
      $stderr << "request: " + msg.call + "\n"
    end
  end
end
