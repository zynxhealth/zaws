module ZAWS
  class Nessusapi
    class Data
      class Agents

          def initialize(shellout, nessusapi)
            @shellout=shellout
            @nessusapi=nessusapi
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

          def view(scanner,verbose)
            details = @nessusapi.filestore.retrieve("scanners_#{scanner}_agents")
            if details.nil?
               load(@nessusapi.resource_agents.list.execute(scanner,verbose),verbose)
               @nessusapi.filestore.store("scanners_#{scanner}_agents",@instance_hash,Time.now + @nessusapi.filestore.timeout)
            else
              load(details,verbose)
            end
            return @instance_raw_data
          end

      end
    end
  end
end