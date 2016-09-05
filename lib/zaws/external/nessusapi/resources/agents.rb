module ZAWS
  class Nessusapi
    class Resources
      class Agents
        def initialize(shellout, nessusapi)
          @shellout=shellout
          @nessusapi=nessusapi
        end

        def list
          @_list ||= (ZAWS::Nessusapi::Resources::Agents::List.new(@shellout, @nessusapi))
          return @_list
        end

      end
    end
  end
end
