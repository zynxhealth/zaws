module ZAWS
  class External
    class AWSCLI
      class Commands
        class EC2
          class DeleteSecurityGroup
            def initialize(shellout=nil, awscli=nil)
              @shellout=shellout
              @awscli=awscli
              clear_settings
              self
            end

            def clear_settings()
              @group_id=nil
              self
            end

            def security_group_id(id)
              @group_id=id
              self
            end

            def get_command
              command = "ec2 delete-security-group"
              command = "#{command} --group-id #{@group_id}" if @group_id
              return command
            end

            def execute(verbose)
              comline=@aws.get_command
              @shellout.cli(comline, verbose)
            end

            def aws
              @aws ||= ZAWS::External::AWSCLI::Commands::AWS.new(self)
              @aws
            end

          end
        end
      end
    end
  end
end

