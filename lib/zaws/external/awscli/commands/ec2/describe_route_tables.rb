module ZAWS
  class External
    class AWSCLI
      class Commands
        class EC2
          class DescribeRouteTables
            def initialize
              @filter=nil
              self
            end

            def filter(filter)
              @filter=filter
              self
            end

            def get_command
              command = "ec2 describe-route-tables"
              command = "#{command} #{@filter.get_command}" if @filter
              return command
            end

          end
        end
      end
    end
  end
end

