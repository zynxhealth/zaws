module ZAWS
  class External
    class AWSCLI
      class Commands
        class EC2
          class AuthorizeSecurityGroupIngress
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
              @group_id=nil
              @cidr=nil
              @protocol=nil
              @port=nil
              @aws=nil
              @source_group=nil
              self
            end

            def source_group(group)
              @source_group=group
              self
            end

            def group_id(id)
              @group_id=id
              self
            end

            def cidr(cidr)
              @cidr=cidr
              self
            end

            def protocol(protocol)
              @protocol=protocol
              self
            end

            def port(port)
              @port=port
              self
            end

            def get_command
              command = "ec2 authorize-security-group-ingress"
              command = "#{command} --group-id #{@group_id}" if @group_id
              command = "#{command} --source-group #{@source_group}" if @source_group
              command = "#{command} --cidr #{@cidr}" if @cidr
              command = "#{command} --protocol #{@protocol}" if @protocol
              command = "#{command} --port #{@port}" if @port
              return command
            end

          end
        end
      end
    end
  end
end

