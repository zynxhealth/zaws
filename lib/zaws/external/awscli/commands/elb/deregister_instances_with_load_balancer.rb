module ZAWS
  class External
    class AWSCLI
      class Commands
        class ELB
          class DeregisterInstancesWithLoadBalancer
            def initialize(shellout=nil, awscli=nil)
              @shellout=shellout
              @awscli=awscli
              clear_settings
              self
            end

            def aws
              @aws ||= ZAWS::External::AWSCLI::Commands::AWS.new(self)
              @aws
            end

            def clear_settings
              @lbn=nil
              @instances=nil
              self
            end


            def instances(id)
              @instances=id
              self
            end

            def load_balancer_name(name)
              @lbn=name
              self
            end

            def get_command
              command = "elb deregister-instances-with-load-balancer"
              command = "#{command} --load-balancer-name #{@lbn}" if @lbn
              command = "#{command} --instances #{@instances}" if @instances
              return command
            end

          end
        end
      end
    end
  end
end

