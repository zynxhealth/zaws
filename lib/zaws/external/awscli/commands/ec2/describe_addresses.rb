module ZAWS
  class External
    class AWSCLI
      class Commands
        class EC2
          class DescribeAddresses
            def initialize(shellout=nil, awscli=nil)
              @shellout=shellout
              @awscli=awscli
              clear_settings
              self
            end

            def clear_settings()
              @filter=nil
              self
            end

            def filter
              @filter ||= ZAWS::External::AWSCLI::Commands::EC2::Filter.new()
              @filter
            end

            def get_command
              command = "ec2 describe-addresses"
              command = "#{command} #{@filter.get_command}" if @filter
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
