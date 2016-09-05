module ZAWS
  class Newrelicapi
    class Resources
      class Servers
        def initialize(shellout, newrelicapi)
          @shellout=shellout
          @newrelicapi=newrelicapi
        end

        def list
          @_list ||= (ZAWS::Newrelicapi::Resources::Servers::List.new(@shellout, @newrelicapi))
          return @_list
        end

      end
    end
  end
end
