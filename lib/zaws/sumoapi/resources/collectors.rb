module ZAWS
  class Sumoapi
    class Resources
      class Collectors
        def initialize(shellout, nessusapi)
          @shellout=shellout
          @nessusapi=nessusapi
        end

        def list
          @_list ||= (ZAWS::Sumoapi::Resources::Collectors::List.new(@shellout, @nessusapi))
          return @_list
        end

      end
    end
  end
end