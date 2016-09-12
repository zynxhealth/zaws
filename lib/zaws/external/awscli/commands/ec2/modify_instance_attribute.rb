module ZAWS
  class External
    class AWSCLI
      class Commands
        class EC2
          class ModifyInstanceAttribute
            def initialize
              clear_settings
              self
            end

            def clear_settings()
              @source_dest_check=nil
              @no_source_dest_check=nil
              @instance_id=nil
              @security_groups=nil
              @aws=nil
              self
            end

            def source_dest_check()
              @source_dest_check=true
              self
            end

            def no_source_dest_check()
              @no_source_dest_check=true
              self
            end

            def instance_id(id)
              @instance_id=id
              self
            end

            def security_groups(sgroups)
              @security_groups=sgroups
              self
            end

            def get_command
              command = "ec2 modify-instance-attribute "
              command = "#{command}--instance-id #{@instance_id} " if @instance_id
              command = "#{command}--no-source-dest-check " if @no_source_dest_check
              command = "#{command}--source-dest-check " if @source_dest_check
              command = "#{command}--groups #{@security_groups} " if @security_groups
              return command
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


