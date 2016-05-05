module ZAWS
  class Nessusapi
    class Resources
      class Scanners
        class List

          def initialize(shellout,nessusapi)
            @shellout=shellout
            @nessusapi=nessusapi
          end

          def execute(verbose=nil)
            @nessusapi.client.get("/scanners")
          end

        end
      end
    end
  end
end