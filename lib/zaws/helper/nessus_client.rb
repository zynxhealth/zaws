require 'excon'
require 'json'

module ZAWS
  module Helper
    class NessusClient

      autoload :NessusCreds, "zaws/helper/nessus_creds"

      # @param [NessusClient::Creds] creds
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
        connection = Excon.new(@creds.url)
        options[:expects] ||= [200]
        options[:method] = method
        options[:path] = path
        options[:headers] ||= {}
        options[:headers]['X-ApiKeys'] = "accessKey=#{@creds.access_key}; secretKey=#{@creds.secret_key}"
        connection.request(options)
      end
      #
      # # Export and download a scan result
      # #
      # # @scan_id
      # # @body
      # #   A hash to be used for the initial request payload.
      # # @return String
      # #   The filepath of the file that was downloaded.
      # def export_download_scan(scan_id, body = {}, download_directory = '', history_id = nil)
      #   body = {
      #       'format' => 'pdf',
      #       'chapters' => ['vuln_hosts_summary'],
      #   }.merge(body)
      #   fail("Invalid format #{body['format']}") unless ['nessus', 'csv', 'db', 'html', 'pdf'].include?(body['format'])
      #   diff = body['chapters'] - %w(vuln_hosts_summary vuln_by_host compliance_exec remediations vuln_by_plugin compliance)
      #   fail("Invalid chapter list #{body['chapters'].inspect}") if diff.length > 0
      #   body['chapters'] = body['chapters'].join(';')
      #   options = {}
      #   options[:query] = {'history_id' => history_id} if history_id
      #   data = post("/scans/#{scan_id}/export", body, options)
      #   file_id = data['file']
      #   fail "Invalid response to export" unless file_id
      #   NessusClient.retry do
      #     data = get("/scans/#{scan_id}/export/#{file_id}/status")
      #     data['status'] == 'ready'
      #   end
      #   # Use request() since we the response is a file, not JSON
      #   response = request('GET', "/scans/#{scan_id}/export/#{file_id}/download")
      #   match = response.headers['content-disposition'].match(/attachment; filename="([^"]+)"/)
      #   fail 'Invalid download response' unless match
      #   target_filename = File.join(download_directory, match[1])
      #   bytes = File.write(target_filename, response.body)
      #   content_length = response.headers['content-length'].to_i
      #   fail "File has wrong number of bytes #{bytes} vs #{content_length} in #{target_filename}" unless bytes == content_length
      #   target_filename
      # end

      # class TimeoutException < RuntimeError
      # end
      #
      # # Retry a block of code multiple times until it returns true, or until
      # # time limit ais reached. This always runs the block at least once.
      # #
      # # Options:
      # #
      # #  [:delay]  Sleep the given number of seconds between each try.
      # #            The default to sleep 2 seconds.
      # #
      # #  [:timeout] Don't try for longer than the given number of seconds.
      # #
      # #  [:message] A message that describes what is being attempted.
      # #
      # #  [:stdout] An IO object to write messages to. Defaults to $stdout.
      # #
      # def self.retry(opts = {}, &blk)
      #   opts = {
      #       delay: 2,
      #       timeout: 30,
      #       stdout: $stdout,
      #   }.merge(opts)
      #
      #   d = opts[:delay]
      #   io = opts[:stdout]
      #   times = 0
      #   start_time = Time.now.to_f
      #   stop_time = Time.now.to_i + opts[:timeout]
      #   io.puts "Waiting for: #{opts[:message]}" if opts[:message]
      #   begin
      #     sleep(d) if times > 0
      #     times += 1
      #     result = blk.call(times)
      #     if (!result) &&(Time.now.to_f - start_time) >= opts[:timeout]
      #       raise TimeoutException.new("Timeout after #{opts[:timeout]} sec.")
      #     end
      #     io.puts "+ retry: #{stop_time-Time.now.to_i} secs left"
      #   end while (!result)
      #   result
      # end
    end
  end
end
