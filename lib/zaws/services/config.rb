module ZAWS
  module Controllers
    class Config

      def initialize(shellout, nessusapi,sumoapi,newrelicapi,awscli)
        @shellout=shellout
        @_nessusapi= nessusapi ? nessusapi : ZAWS::Nessusapi.new(@shellout)
        @_sumoapi= sumoapi ? sumoapi : ZAWS::Sumoapi.new(@shellout)
        @_newrelicapi= newrelicapi ? newrelicapi : ZAWS::Newrelicapi.new(@shellout)
        @_awscli= awscli ? awscli : ZAWS::AWSCLI.new(@shellout)
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

      def awscli
        return @_awscli
      end

    end
  end
end
