module ZAWS
  class External
    class AWSCLI
      class Commands
        class ELB
          class DescribeLoadBalancers
            def initialize(shellout=nil, awscli=nil)
              @shellout=shellout
              @awscli=awscli
              @aws=nil
              self
            end

            def get_command
              command = "elb describe-load-balancers"
              return command
            end

            def aws
              @aws ||= ZAWS::External::AWSCLI::Commands::AWS.new(self)
              @aws
            end

          end
        end
      end
    end
  end
end

