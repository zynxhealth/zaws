module ZAWS
  class AWSCLI
    class Commands
      class EC2
        class CreateVPC

          def initialize(shellout, awscli)
            @shellout=shellout
            @awscli=awscli
          end

          def execute(region, view, cidr,  textout=nil, verbose=nil,profile=nil)
            comline="aws --output #{view} --region #{region} ec2 create-vpc --cidr-block #{cidr}"
            @awscli.data_ec2.vpc.load(comline, @shellout.cli(comline, verbose), textout)
          end

        end
      end
    end
  end
end
