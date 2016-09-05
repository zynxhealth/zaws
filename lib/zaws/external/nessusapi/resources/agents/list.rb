module ZAWS
  class Nessusapi
    class Resources
      class Agents
        class List

          def initialize(shellout,nessusapi)
            @shellout=shellout
            @nessusapi=nessusapi
          end

          def execute(scanner,verbose=nil)
            @nessusapi.client.get("/scanners/#{scanner}/agents")
          end

        end
      end
    end
  end
end