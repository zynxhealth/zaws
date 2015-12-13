require 'spec_helper'

describe ZAWS::Services::EC2::VPC do

  let(:r_vpcs) { <<-eos
  	{
    "Vpcs": [
        {
            "VpcId": "vpc-abcdefgh",
            "InstanceTenancy": "default",
            "Tags": [
                {
                    "Value": "use1-customer",
                    "Key": "Name"
                },
                {
                    "Value": "use1-customer",
                    "Key": "externalid"
                }
            ],
            "State": "available",
            "DhcpOptionsId": "dopt-abcdefgh",
            "CidrBlock": "10.0.0.0/16",
            "IsDefault": false
        }]
    }
  eos
  }

  let(:p_region) { "us-west-1" }

  let(:options) { {:region => p_region,
                   :verbose => nil,
                   :availabilitytimeout => 30,
                   :nagios => false,
                   :undofile => false} }

  before(:each) {
    @textout=double('outout')
    @shellout=double('ZAWS::Helper::Shell')
    @command_subnet = ZAWS::Command::Subnet.new([], options, {});
    @aws=ZAWS::AWS.new(@shellout, ZAWS::AWSCLI.new(@shellout))
    @command_subnet.aws=@aws
    @command_subnet.out=@textout
    @command_subnet.print_exit_code = true
  }

  describe "#view" do

    it "view subnets, table view" do
      expect(@shellout).to receive(:cli).with("aws --output table --region #{p_region} ec2 describe-vpcs", nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @aws.ec2.vpc.view(p_region, 'table', @textout)
    end

  end

end
