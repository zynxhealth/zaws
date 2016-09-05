module ZAWS
  class External
    class AWSCLI
      class Generators
        class API
          class EC2
            class DescribeSubnets
              def initialize
                @filter=nil
                self
              end

              def filter(filter)
                @filter=filter
                self
              end

              def get_command
                command = "ec2 describe-subnets"
                command = "#{command} #{@filter.get_command}" if @filter
                return command
              end

            end
          end
        end
      end
    end
  end
end

