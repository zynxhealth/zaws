module ZAWS
  module Controllers
    class Nessus

      def initialize(shellout, nessusapi)
        @shellout=shellout
        @_nessusapi= nessusapi ? nessusapi : ZAWS::Nessusapi.new(@shellout)
      end

      def nessusapi
        return @_nessusapi
      end

      def scanners
        @_scanners ||= (ZAWS::Services::Nessus::Scanners.new(@shellout, self))
      end

      def agents
        @_agents ||= (ZAWS::Services::Nessus::Agents.new(@shellout, self))
      end

    end
  end
end
