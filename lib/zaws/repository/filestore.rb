require 'yaml'
require 'date'

module ZAWS
  class Repository
    class Filestore
      attr_accessor :location
      attr_accessor :timeout

      def initialize()
      end

      def store(key,value,expires)
         storage = {}
         storage['value']=value
         storage['expires']=expires.strftime('%s')
         File.open("#{@location}/#{key}","w") do |file|
           file.write storage.to_yaml
         end
      end

      def retrieve(key)
        if File.exists?("#{@location}/#{key}")
          storage = YAML.load(File.read("#{@location}/#{key}"))
          if Date.strptime(storage['expires'], '%s')< DateTime.now
            return storage['value']
          end
        end
      end
    end
  end
end