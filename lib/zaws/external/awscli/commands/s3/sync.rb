module ZAWS
  class External
    class AWSCLI
      class Commands
        class S3
          class Sync
            def initialize(shellout=nil, awscli=nil)
              @shellout=shellout
              @awscli=awscli
              clear_settings
              self
            end

            def clear_settings
              @aws=nil
              @source_name=nil
              @target_name=nil
            end

            def source_name(source_name)
              @source_name=source_name
              self
            end

            def target_name(target_name)
              @target_name=target_name
              self
            end

            def get_command
              command = "s3 sync"
              command = "#{command} #{@source_name}" if @source_name
              command = "#{command} #{@target_name}" if @target_name
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

