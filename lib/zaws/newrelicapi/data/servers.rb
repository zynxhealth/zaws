module ZAWS
  class Newrelicapi
    class Data
      class Servers

        def initialize(shellout, newrelicapi)
          @shellout=shellout
          @newrelicapi=newrelicapi
          @instance_hash=nil
        end

        def validJSON
          return (@instance_hash.nil?)
        end

        def load(data, verbose)
          @instance_raw_data = data
          verbose.puts(@instance_raw_data) if verbose
          @instance_hash=data
        end

        def view(verbose)
          details = @newrelicapi.filestore.retrieve("serversjson")
          if details.nil?
            load(@newrelicapi.resource_servers.list.execute(verbose),verbose)
            @newrelicapi.filestore.store("serversjson",@instance_hash,Time.now + @newrelicapi.filestore.timeout)
          else
            load(details,verbose)
          end
          return @instance_raw_data
        end
      end
    end
  end
end
