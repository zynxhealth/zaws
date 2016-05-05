require 'excon'
require 'json'

module ZAWS
  class Sumoapi
    class SumoClient

      autoload :SumoCreds, "zaws/sumoapi/sumo_creds"

      # @param [SumoClient::Creds] creds
      def initialize(creds)
        @creds = creds
      end

      def url
        @creds.url
      end

      # Make a GET request expecting a JSON response.
      def get(path, query = {}, options = {})
        # Handle nil or empty Array
        options[:query] = query.to_h if query
        options[:idempotent] = true
        json_request('GET', path, options)
      end

      # Make a POST request expecting a JSON response.
      def post(path, body, options = {})
        options[:body] = body
        json_request('POST', path, options)
      end

      # Make a PUT request expecting a JSON response.
      def put(path, body, options = {})
        options[:body] = body
        json_request('PUT', path, options)
      end

      def delete(path, options = {})
        options[:idempotent] = true
        json_request('DELETE', path, options)
      end

      def json_request(method, path, options = {})
        if options[:body] && !options[:body].instance_of?(String)
          options[:body] = options[:body].to_json
        end
        options[:headers] ||= {}
        options[:headers]['Content-Type'] = 'application/json'
        response = request(method, path, options)
        JSON.parse(response.body) if (response.body.length > 0 && response.headers['content-type'].match(/json/))
      end

      def request(method, path, options = {})
        connection = Excon.new(@creds.url, :user => "#{@creds.access_id}", :password => "#{@creds.access_key}")
        options[:expects] ||= [200]
        options[:method] = method
        options[:path] = path
        connection.request(options)
      end
    end
  end
end
