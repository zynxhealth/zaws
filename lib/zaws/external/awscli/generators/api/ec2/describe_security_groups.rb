module ZAWS
  class External
    class AWSCLI
      class Generators
        class API
          class EC2
            class DescribeSecurityGroups
              def initialize
                @filter=nil
                self
              end

              def filter(filter)
                @filter=filter
                self
              end

              def get_command
                command = "ec2 describe-security-groups"
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

