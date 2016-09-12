module ZAWS
  class External
    class AWSCLI
      class Commands
        class S3
          class Mb
            def initialize(shellout=nil, awscli=nil)
              @shellout=shellout
              @awscli=awscli
              clear_settings
              self
            end

            def clear_settings
              @aws=nil
              @name=nil
            end

            def bucket_name(name)
              @name=name
              self
            end

            def get_command
              command = "s3 mb"
              command = "#{command} s3://#{@name}" if @name
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

