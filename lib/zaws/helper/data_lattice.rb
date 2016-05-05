module ZAWS
  module Helper
    class DataLattice

      def initialize()
        @lattice = nil
      end

      def load(data)
         nessus_agents(data)
         aws_instance(data)
         sumologic_collector(data)
      end

      def save(filename)

      end
    end
  end
end


