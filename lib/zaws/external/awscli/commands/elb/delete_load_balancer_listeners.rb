module ZAWS
  class External
    class AWSCLI
      class Commands
        class ELB
          class DeleteLoadBalancerListeners
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
              @ports_array=nil
              self
            end


            def load_balancer_name(name)
              @lbn=name
              self
            end

            def listeners(ports)
              @ports_array=ports
              self
            end

            def get_command
              command = "elb delete-load-balancer-listeners"
              command = "#{command} --load-balancer-name #{@lbn}" if @lbn
              command = "#{command} --load-balancer-ports '#{(@ports_array.map { |x| x["Listener"]["LoadBalancerPort"]}).join(' ')}'" if @ports_array
              return command
            end

          end
        end
      end
    end
  end
end

