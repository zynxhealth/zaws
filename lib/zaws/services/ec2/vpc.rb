require 'json'
require 'netaddr'
require 'timeout'

module ZAWS
  module Services
    module EC2
      class VPC

        def initialize(shellout, aws)
          @shellout=shellout
          @aws=aws
        end

        def view(region, view, textout=nil, verbose=nil)
          @aws.awscli.command_ec2.DescribeVPCs.execute(region, view, textout, verbose)
          @aws.awscli.data_ec2.subnet.view()
        end
      end
    end
  end
end

