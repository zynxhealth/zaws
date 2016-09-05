module ZAWS
  class Sumoapi
    class Data
      class Sources

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

        def view(verbose,sourceid)
          details = @sumoapi.filestore.retrieve("sources#{sourceid}")
          if details.nil?
            load(@sumoapi.resource_sources.list.execute(verbose,sourceid),verbose)
            @sumoapi.filestore.store("sources#{sourceid}",@instance_hash,Time.now + @sumoapi.filestore.timeout)
          else
            load(details,verbose)
          end
          return @instance_raw_data
        end
      end
    end
  end
end
