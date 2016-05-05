module ZAWS
  module Controllers
    class Newrelic

      def initialize(shellout, newrelicapi)
        @shellout=shellout
        @_newrelicapi= newrelicapi ? newrelicapi : ZAWS::Sumoapi.new(@shellout)
      end

      def newrelicapi
        return @_newrelicapi
      end

      def servers
        @_servers ||= (ZAWS::Services::Newrelic::Servers.new(@shellout, self))
      end


    end
  end
end
