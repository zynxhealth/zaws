module ZAWS
  class External
    class AWSCLI
      class Commands
        class S3
          class Ls
            def initialize(shellout=nil, awscli=nil)
              @shellout=shellout
              @awscli=awscli
              clear_settings
              self
            end

            def clear_settings
              @aws=nil
            end

            def get_command
              command = "s3 ls"
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

