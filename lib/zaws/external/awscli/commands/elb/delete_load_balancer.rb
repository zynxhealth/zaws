module ZAWS
  class External
    class AWSCLI
      class Commands
        class ELB
          class DeleteLoadBalancer
            def initialize(shellout=nil, awscli=nil)
              @shellout=shellout
              @awscli=awscli
              clear_settings
            end

            def aws
              @aws ||= ZAWS::External::AWSCLI::Commands::AWS.new(self)
              @aws
            end

            def clear_settings
              @aws=nil
              @lbname=nil
            end

            def load_balancer_name(name)
              @lbname=name
              self
            end

            def get_command
              command = "elb delete-load-balancer"
              command = "#{command} --load-balancer-name #{@lbname}" if @lbname
              return command
            end

          end
        end
      end
    end
  end
end

