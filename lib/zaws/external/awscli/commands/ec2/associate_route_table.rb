module ZAWS
  class External
    class AWSCLI
      class Commands
        class EC2
          class AssociateRouteTable
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
              @subnet_id=nil
              @route_table_id=nil
              @aws=nil
              self
            end

            def subnet_id(id)
              @subnet_id=id
              self
            end

            def route_table_id(id)
              @route_table_id=id
              self
            end

            def get_command
              command = "ec2 associate-route-table"
              command = "#{command} --subnet-id #{@subnet_id}" if @subnet_id
              command = "#{command} --route-table-id #{@route_table_id}" if @route_table_id
              return command
            end
          end
        end
      end
    end
  end
end

