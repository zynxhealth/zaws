module ZAWS
  module Controllers
    class Sumo

      def initialize(shellout, sumoapi)
        @shellout=shellout
        @_sumoapi= sumoapi ? sumoapi : ZAWS::Sumoapi.new(@shellout)
      end

      def sumoapi
        return @_sumoapi
      end

      def collectors
        @_collectors ||= (ZAWS::Services::Sumo::Collectors.new(@shellout, self))
      end


    end
  end
end
