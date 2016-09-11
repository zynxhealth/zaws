require "#{File.dirname(__FILE__)}/../../data/ec2/subnet"

module ZAWS
  class External
    class AWSCLI
      class Commands
        class EC2
          class CreateSubnet < ZAWS::AWSCLI::Data::EC2::Subnet

            def initialize(shellout=nil, awscli=nil)
              super(shellout, awscli)
              @shellout=shellout
              @awscli=awscli
              clear_settings
            end

            def execute(verbose)
              comline=@aws.get_command
              load(comline, @shellout.cli(comline, verbose), verbose)
            end

            def aws
              @aws ||= ZAWS::External::AWSCLI::Commands::AWS.new(self)
              @aws
            end

            def clear_settings
              @aws=nil
              @vpc_id=nil
              @cidr=nil
              @az=nil
            end

            def vpc_id(vpc_id)
              @vpc_id=vpc_id
              self
            end

            def cidr(cidr)
              @cidr=cidr
              self
            end

            def availability_zone(az)
              @az=az
              self
            end

            def get_command
              command = "ec2 create-subnet"
              command = "#{command} --vpc-id #{@vpc_id}" if @vpc_id
              command = "#{command} --cidr-block #{@cidr}" if @cidr
              command = "#{command} --availability-zone #{@az}" if @az
              return command
            end

          end
        end
      end
    end
  end
end
