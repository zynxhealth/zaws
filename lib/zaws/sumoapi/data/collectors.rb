module ZAWS
  class Sumoapi
    class Data
      class Collectors

        def initialize(shellout, sumoapi)
          @shellout=shellout
          @sumoapi=sumoapi
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
          details = @sumoapi.filestore.retrieve("collectors")
          if details.nil?
            load(@sumoapi.resource_collectors.list.execute(verbose),verbose)
            @sumoapi.filestore.store("collectors",@instance_hash,Time.now + @sumoapi.filestore.timeout)
          else
            load(details,verbose)
          end
          return @instance_raw_data
        end
      end
    end
  end
end