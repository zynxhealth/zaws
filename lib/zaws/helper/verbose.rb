module ZAWS
  module Helper
    class Verbose

      def self.output(available)
        if available
          return $stdout
        else
          return nil
        end

      end
    end
  end
end
