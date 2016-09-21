module ZAWS
  class External
    class AWSCLI
      class Commands
        class ELB
          class CreateLoadBalancer
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

            def listeners(listners_array)
              @listeners_array=listners_array
              self
            end

            def subnets(subnet_array)
              @subnet_array=subnet_array
              self
            end

            def security_groups(security_groups)
              @security_groups=security_groups
              self
            end

            def get_command
              command = "elb create-load-balancer"
              command = "#{command} --load-balancer-name #{@lbname}" if @lbname
              command = "#{command} --listeners '[#{@listeners_array[0]["Listener"].to_json}]'" if @listeners_array
              if @subnet_array
                command = "#{command} --subnets #{@subnet_array.join(" ")}"
              end
              if @security_groups
                command = "#{command} --security-groups #{@security_groups.join(" ")}"
              end
              return command
            end

          end
        end
      end
    end
  end
end

