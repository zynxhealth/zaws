require 'yaml'

module ZAWS
  class Newrelicapi
    class NewrelicCreds
        # Simple container for credentials
        class Creds

          # @param [String] newrelic_url
          # @param [String] api_key
          def initialize(newrelic_url, api_key)
            @creds = {}
            @creds[:url] = newrelic_url
            @creds[:api_key] = api_key
          end

          def url
            fetch_creds[:url]
          end

          def api_key
            fetch_creds[:api_key]
          end

          private

          def fetch_creds
            # Nothing to do in the base class
            @creds
          end
        end

        # Subclass that loads creds from a YAML file.
        class Creds::YamlFile < Creds
          FILENAME = '.newrelic.yml'

          def initialize(home)
            @creds_file = File.join(home, FILENAME)
          end

          private

          def fetch_creds
            unless @creds
              fail("Missing file #{@creds_file}") unless File.exist?(@creds_file)
              file_creds = YAML.load(File.read(@creds_file))
              file_creds ||= {}
              ['url', 'apiKey'].each do |key|
                fail("Missing #{key} value in #{@creds_file}") unless file_creds[key]
              end
              @creds = {}
              @creds[:url] = file_creds['url']
              @creds[:api_key] = file_creds['apiKey']
            end
            @creds
          end
        end
    end
  end
end