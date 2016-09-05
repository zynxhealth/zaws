module ZAWS
  class Newrelicapi
    class Resources
      class Servers
        class List

          def initialize(shellout,newrelicapi)
            @shellout=shellout
            @newrelicapi=newrelicapi
          end

          def execute(verbose=nil)
            @newrelicapi.client.get("/v2/servers.json")
          end

        end
      end
    end
  end
end
