module ZAWS
  class External
    class AWSCLI
      class Commands
        class EC2
          class DescribeRouteTables
            def initialize(shellout=nil, awscli=nil)
              #super(shellout, awscli)
              @shellout=shellout
              @awscli=awscli
              clear_settings
              self
            end


            def aws
              @aws ||= ZAWS::External::AWSCLI::Commands::AWS.new(self)
              @aws
            end

            def filter
              @filter ||= ZAWS::External::AWSCLI::Commands::EC2::Filter.new()
              @filter
            end

            def clear_settings
              @aws=nil
              @filter=nil
              @tags=nil
            end

            def get_command
              command = "ec2 describe-route-tables"
              command = "#{command} #{@filter.get_command}" if @filter
              return command
            end

          end
        end
      end
    end
  end
end

