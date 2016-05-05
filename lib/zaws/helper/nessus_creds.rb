require 'yaml'

module ZAWS
  module Helper
    class NessusCreds
        # Simple container for credentials
        class Creds

          # @param [String] nessus_url
          # @param [String] access_key
          # @param [String] secret_key
          def initialize(nessus_url, access_key, secret_key)
            @creds = {}
            @creds[:url] = nessus_url
            @creds[:access_key] = access_key
            @creds[:secret_key] = secret_key
          end

          def url
            fetch_creds[:url]
          end

          def access_key
            fetch_creds[:access_key]
          end

          def secret_key
            fetch_creds[:secret_key]
          end

          private

          def fetch_creds
            # Nothing to do in the base class
            @creds
          end
        end

        # Subclass that loads creds from a YAML file.
        class Creds::YamlFile < Creds
          FILENAME = '.nessus.yml'

          def initialize(home)
            @creds_file = File.join(home, FILENAME)
          end

          private

          def fetch_creds
            unless @creds
              fail("Missing file #{@creds_file}") unless File.exist?(@creds_file)
              file_creds = YAML.load(File.read(@creds_file))
              file_creds ||= {}
              ['url', 'secretKey', 'accessKey'].each do |key|
                fail("Missing #{key} value in #{@creds_file}") unless file_creds[key]
              end
              @creds = {}
              @creds[:url] = file_creds['url']
              @creds[:access_key] = file_creds['accessKey']
              @creds[:secret_key] = file_creds['secretKey']
            end
            @creds
          end
        end
    end
  end
end