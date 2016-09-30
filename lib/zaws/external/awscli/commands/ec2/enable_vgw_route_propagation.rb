module ZAWS
  class External
    class AWSCLI
      class Commands
        class EC2
          class EnableVgwRoutePropagation

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
              @route_table_id=nil
              @dest_cidr_block=nil
              @instance_id=nil
            end

            def route_table_id(id)
              @route_table_id=id
              self
            end

            def gateway_id(id)
              @gateway_id=id
              self
            end

            def get_command
              command = "ec2 enable-vgw-route-propagation"
              command = "#{command} --route-table-id #{@route_table_id}" if @route_table_id
              command = "#{command} --gateway-id #{@gateway_id}" if @gateway_id
              return command
            end

          end
        end
      end
    end
  end
end
