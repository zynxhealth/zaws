module ZAWS
  module Helper
    class ProcessHash
      def self.keep(target, list_of_strings)
        result=''
        if target.instance_of?(Hash)
          target.each do |k, v|
            list_of_strings.each do |x|
              if k.downcase.include? x.downcase
                result = {} if result.eql?('')
                result[k]=v
              end
            end
            if result.eql?('')
              recurse=self.keep(v, list_of_strings)
            end
            if !recurse.nil? and !recurse.eql?('')
              result = {} if result.eql?('')
              result[k]=recurse
            end
          end
        end
        if target.instance_of?(String)
          list_of_strings.each do |x|
            if target.downcase.include? x.downcase
              result=target
            end
          end
        end
        if target.instance_of?(Array)
          target.each do |y|
            iterate=self.keep(y, list_of_strings)
            if !iterate.nil? and !iterate.eql?('')
              result = [] if result.eql?('')
              result << iterate
            end
          end
        end
        if result.nil?
          return ''
        end
        return result
      end
    end
  end
end

