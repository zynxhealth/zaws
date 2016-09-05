module ZAWS
  class AWSCLI
    class Commands
      class EC2
        class DescribeVpcPeeringConnections

          def initialize(shellout, awscli)
            @shellout=shellout
            @awscli=awscli
          end

          def execute(region, view, filters, verbose=nil,profile=nil)
            comline="aws --output #{view} --region #{region} ec2 describe-vpc-peering-connections"
            comline=comline + " --profile #{profile}" unless profile.nil?
            comline = ZAWS::Helper::Filter.filter(comline,filters) if filters.length > 0
            @awscli.data_ec2.vpc.load(comline, @shellout.cli(comline, verbose),verbose)
          end

        end
      end
    end
  end
end