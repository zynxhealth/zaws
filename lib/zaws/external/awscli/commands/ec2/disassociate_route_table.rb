module ZAWS
  class External
    class AWSCLI
      class Commands
        class EC2
          class DisassociateRouteTable
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
              @association_id=nil
              @aws=nil
              self
            end

            def association_id(id)
              @association_id=id
              self
            end

            def get_command
              command = "ec2 disassociate-route-table"
              command = "#{command} --association-id #{@association_id}" if @association_id
              return command
            end
          end
        end
      end
    end
  end
end

