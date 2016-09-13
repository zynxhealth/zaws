module ZAWS
  class External
    class AWSCLI
      class Commands
        class EC2
          class CreateRouteTable
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
              @vpc_id=nil
            end

            def vpc_id(vpc_id)
              @vpc_id=vpc_id
              self
            end

            def get_command
              command = "ec2 create-route-table"
              command = "#{command} --vpc-id #{@vpc_id}" if @vpc_id
              return command
            end

          end
        end
      end
    end
  end
end

