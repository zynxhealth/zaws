module ZAWS
  module Helper
    class Filter

      def self.filter(comline, filters)
        result = comline + " --filter"
        filters.each do |key, item|
          result = result + " 'Name=#{key},Values=#{item}'"
        end
        return result
      end

    end
  end
end
