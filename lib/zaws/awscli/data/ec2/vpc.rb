module ZAWS
  class AWSCLI
    class Data
      class EC2
        class VPC

          def initialize(shellout, ec2)
            @shellout=shellout
            @ec2=ec2
            @vpc_hash=nil
          end

          def validJSON
            return (@vpc_hash.nil?)
          end

          def load(command, data, textout)
            @vpc_raw_data = data
            textout.puts(@vpc_raw_data) if textout
            @vpc_hash=nil
            begin
              @vpc_hash =JSON.parse(data)
            rescue JSON::ParserError => e
            end
          end

          def view()
            return @vpc_raw_data
          end

        end
      end
    end
  end
end
