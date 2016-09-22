module ZAWS
  module Helper
    class ProcessHash
      def self.keep(target, list_of_strings)
        result = {}
        target.each do |k, v|
          found_in_key=false
          list_of_strings.each do |x|
            if k.downcase.include? x.downcase
              result[k]=v
              found_in_key=true
            end
          end
          if !found_in_key
            if v.instance_of?(String)
              list_of_strings.each do |x|
                if v.downcase.include? x.downcase
                  result[k]=v
                end
              end
            end
            if v.instance_of?(Hash)
              recurse=self.keep(v, list_of_strings)
              if !recurse.empty?
                result[k]=recurse
              end
            end
            if v.instance_of?(Array)
              v.each do |y|
                iterate=self.keep(y, list_of_strings)
                if !iterate.empty?
                  result[k] ||= []
                  result[k] << iterate
                end
              end
            end
          end
        end
        if result.empty?
          return ''
        end
        return result
      end
    end
  end
end

