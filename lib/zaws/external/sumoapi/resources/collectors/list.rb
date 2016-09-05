module ZAWS
  class Sumoapi
    class Resources
      class Collectors
        class List

          def initialize(shellout,sumoapi)
            @shellout=shellout
            @sumoapi=sumoapi
          end

          def execute(verbose=nil)
            @sumoapi.client.get("/api/v1/collectors")
          end

        end
      end
    end
  end
end