module ZAWS
  module Controllers
    class AI

      def initialize(shellout, nessusapi,sumoapi,newrelicapi)
        @shellout=shellout
        @_nessusapi= nessusapi ? nessusapi : ZAWS::Nessusapi.new(@shellout)
        @_sumoapi= sumoapi ? sumoapi : ZAWS::Sumoapi.new(@shellout)
        @_newrelicapi= newrelicapi ? newrelicapi : ZAWS::Newrelicapi.new(@shellout)
      end

      def nessusapi
        return @_nessusapi
      end

      def sumoapi
        return @_sumoapi
      end

      def newrelicapi
        return @_newrelicapi
      end

      def query
        @_query ||= (ZAWS::Services::AI::Query.new(@shellout, self))
      end

    end
  end
end