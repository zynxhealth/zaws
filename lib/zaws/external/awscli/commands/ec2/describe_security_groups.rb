require "#{File.dirname(__FILE__)}/../../data/ec2/security_group"
require "#{File.dirname(__FILE__)}/../aws"
require "#{File.dirname(__FILE__)}/filter"

module ZAWS
  class External
    class AWSCLI
      class Commands
        class EC2
          class DescribeSecurityGroups < ZAWS::External::AWSCLI::Data::EC2::SecurityGroup
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
              command = "ec2 describe-security-groups"
              command = "#{command} #{@filter.get_command}" if @filter
              return command
            end

          end
        end
      end
    end
  end
end

