require "#{File.dirname(__FILE__)}/../../data/ec2/subnet"

module ZAWS
  class External
    class AWSCLI
      class Commands
        class EC2
          class DescribeSubnets < ZAWS::AWSCLI::Data::EC2::Subnet

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
            end

            def get_command
              command = "ec2 describe-subnets"
              command = "#{command} #{@filter.get_command}" if @filter
              return command
            end

            def initialize(shellout=nil, awscli=nil)
              super(shellout, awscli)
              @shellout=shellout
              @awscli=awscli
              clear_settings
            end

            def execute(verbose=nil)
              comline=@aws.get_command
              load(comline, @shellout.cli(comline, verbose), verbose)
            end

          end
        end
      end
    end
  end
end
