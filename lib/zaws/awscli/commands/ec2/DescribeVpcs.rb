module ZAWS
  class AWSCLI
    class Commands
      class EC2
        class DescribeVPCs

          def initialize(shellout, awscli)
            @shellout=shellout
            @awscli=awscli
          end

          def execute(region, view,  textout=nil, verbose=nil)
            comline="aws --output #{view} --region #{region} ec2 describe-vpcs"
            @awscli.data_ec2.vpc.load(comline, @shellout.cli(comline, verbose), textout)
          end

        end
      end
    end
  end
end