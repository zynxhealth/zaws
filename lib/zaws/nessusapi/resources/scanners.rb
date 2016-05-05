module ZAWS
  class Nessusapi
    class Resources
      class Scanners
        def initialize(shellout, nessusapi)
          @shellout=shellout
          @nessusapi=nessusapi
        end

        def list
          @_list ||= (ZAWS::Nessusapi::Resources::Scanners::List.new(@shellout, @nessusapi))
          return @_list
        end

      end
    end
  end
end
