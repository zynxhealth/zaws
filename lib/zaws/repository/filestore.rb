require 'yaml'
require 'date'
require 'digest/md5'

module ZAWS
  class Repository
    class Filestore
      attr_accessor :location
      attr_accessor :timeout

      def initialize()
      end

      def store(key,value,expires,command=nil)
         storage = {}
         storage['value']=value
         storage['expires']=expires.strftime('%s')
         if command.nil?
           filename=key
         else
           storage['command']=command
           filename=key+Digest::MD5.hexdigest(command)
         end
         File.open("#{@location}/#{filename}","w") do |file|
           file.write storage.to_yaml
         end
      end

      def retrieve(key,command=nil)
        if command.nil?
           filename=key
        else
           filename=key+Digest::MD5.hexdigest(command)
        end
        if File.exists?("#{@location}/#{filename}")
          storage = YAML.load(File.read("#{@location}/#{filename}"))
          if Date.strptime(storage['expires'], '%s')< DateTime.now
            return storage['value']
          end
        end
      end

    end
  end
end