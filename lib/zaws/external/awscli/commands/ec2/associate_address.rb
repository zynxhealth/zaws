module ZAWS
  class External
    class AWSCLI
      class Commands
        class EC2
          class AssociateAddress
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
              @instance_id=nil
              @allocation_id=nil
              @aws=nil
              self
            end

            def instance_id(id)
              @instance_id=id
              self
            end

            def allocation_id(id)
              @allocation_id=id
              self
            end

            def get_command
              command = "ec2 associate-address"
              command = "#{command} --instance-id #{@instance_id}" if @instance_id
              command = "#{command} --allocation-id #{@allocation_id}" if @allocation_id
              return command
            end
          end
        end
      end
    end
  end
end

