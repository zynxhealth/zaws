module ZAWS
  class External
    class AWSCLI
      class Commands
        class EC2
          class TerminateInstances
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
              @instance_id=nil
            end

            def instance_id(id)
              @instance_id=id
              self
            end

            def get_command
              command = "ec2 terminate-instances"
              command = "#{command} --instance-ids #{@instance_id}" if @instance_id
              return command
            end

          end
        end
      end
    end
  end
end

