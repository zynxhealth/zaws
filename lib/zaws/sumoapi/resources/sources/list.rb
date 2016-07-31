module ZAWS
  class Sumoapi
    class Resources
      class Sources
        class List

          def initialize(shellout,sumoapi)
            @shellout=shellout
            @sumoapi=sumoapi
          end

          def execute(verbose=nil,sourceid)
            @sumoapi.client.get("/api/v1/collectors/#{sourceid}/sources")
          end

        end
      end
    end
  end
end
