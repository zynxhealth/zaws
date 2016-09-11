module ZAWS
  class External
    class AWSCLI
      class Commands
        class EC2
          class ModifyInstanceAttribute
            def initialize
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

            def get_command
              command = "ec2 modify-instance-attribute "
              command = "#{command}--instance-id=#{@instance_id} " if @instance_id
              command = "#{command}--no-source-dest-check " if @no_source_dest_check
              command = "#{command}--source-dest-check " if @source_dest_check
              return command
            end

          end
        end
      end
    end
  end
end


