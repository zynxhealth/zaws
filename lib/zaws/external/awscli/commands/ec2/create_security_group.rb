require "#{File.dirname(__FILE__)}/../../data/ec2/security_group"
require "#{File.dirname(__FILE__)}/../aws"
require "#{File.dirname(__FILE__)}/filter"

module ZAWS
  class External
    class AWSCLI
      class Commands
        class EC2
          class CreateSecurityGroup
            def initialize(shellout=nil, awscli=nil)
              @shellout=shellout
              @awscli=awscli
              clear_settings
            end

            def aws
              @aws ||= ZAWS::External::AWSCLI::Commands::AWS.new(self)
              @aws
            end

            def clear_settings
              @aws=nil
              @vpc_id=nil
              @group_name=nil
              @description=nil
            end

            def vpc_id(vpc_id)
              @vpc_id=vpc_id
              self
            end

            def group_name(name)
              @group_name=name
              self
            end

            def description(description)
              @description=description
              self
            end

            def get_command
              command = "ec2 create-security-group"
              command = "#{command} --vpc-id #{@vpc_id}" if @vpc_id
              command = "#{command} --group-name #{@group_name}" if @group_name
              command = "#{command} --description '#{@description}'" if @description
              return command
            end

          end
        end
      end
    end
  end
end

