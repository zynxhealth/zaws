module ZAWS
  class External
    class AWSCLI
      class Commands
        class EC2
          class DisassociateAddress
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
              @associate_id=nil
              @aws=nil
              self
            end

            def association_id(id)
              @associate_id=id
              self
            end

            def get_command
              command = "ec2 disassociate-address"
              command = "#{command} --association-id #{@associate_id}" if @associate_id
              return command
            end

          end
        end
      end
    end
  end
end

