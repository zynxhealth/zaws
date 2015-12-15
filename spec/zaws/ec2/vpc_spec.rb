require 'spec_helper'

describe ZAWS::Services::EC2::VPC do


  let(:p_externalid){ "use1-customer"}

  let(:p_cidr){ "10.0.0.0/16"}

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
                    "Value": "#{p_externalid}",
                    "Key": "externalid"
                }
            ],
            "State": "available",
            "DhcpOptionsId": "dopt-abcdefgh",
            "CidrBlock": "#{p_cidr}",
            "IsDefault": false
        }]
    }
  eos
  }

  let(:r_vpcs_no_externalid) { <<-eos
  	{
    "Vpcs": [
        {
            "VpcId": "vpc-abcdefgh",
            "InstanceTenancy": "default",
            "Tags": [
                {
                    "Value": "use1-customer",
                    "Key": "Name"
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

  let(:r_check_management_data_fail_externalid) { "FAIL: VPC 'vpc-abcdefgh' does not have the tag 'externalid' required to manage vpc with ZAWS." }

  let(:r_vpcs_no_name) { <<-eos
  	{
    "Vpcs": [
        {
            "VpcId": "vpc-abcdefgh",
            "InstanceTenancy": "default",
            "Tags": [
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

  let(:r_check_management_data_warning_name) { "WARNING: VPC 'vpc-abcdefgh' does not have the tag 'Name' which usually assists humans." }

  let(:p_region) { "us-west-1" }

  let(:options) { {:region => p_region,
                   :verbose => nil,
                   :availabilitytimeout => 30,
                   :nagios => false,
                   :undofile => false,
                   :viewtype => 'json'} }

  let(:c_describe_vpcs) { "aws --output json --region #{p_region} ec2 describe-vpcs" }

  let(:c_create_vpc) { "aws --output json --region #{p_region} ec2 create-vpc --cidr-block #{p_cidr}" }

  let(:c_create_tags) { "aws --output json --region #{p_region} ec2 create-tags --resources vpc-abcdefgh --tags Key=externalid,Value=use1-customer" }

  let(:c_create_tags_Name) { "aws --output json --region #{p_region} ec2 create-tags --resources vpc-abcdefgh --tags Key=Name,Value=use1-customer" }

  let(:r_vpc_available) { '{ "Vpc": { "VpcId":"vpc-abcdefgh", "State": "available" } }' }

  let(:r_vpc_pending) { '{ "Vpc": { "VpcId":"vpc-abcdefgh", "State": "pending" } }' }

  let(:no_action_vpc_exists) { ZAWS::Helper::Output.colorize("No action needed. VPC exists already.", AWS_consts::COLOR_GREEN) }
  let(:vpc_created) { ZAWS::Helper::Output.colorize("VPC created.", AWS_consts::COLOR_YELLOW) }

  before(:each) {
    @textout=double('outout')
    @shellout=double('ZAWS::Helper::Shell')
    @command_vpc = ZAWS::Command::VPC.new([], options, {});
    @aws=ZAWS::AWS.new(@shellout, ZAWS::AWSCLI.new(@shellout))
    @command_vpc.aws=@aws
    @command_vpc.out=@textout
    @command_vpc.print_exit_code = true
  }

  describe "#view" do

    it "view vpcs, table view" do
      expect(@shellout).to receive(:cli).with("aws --output json --region #{p_region} ec2 describe-vpcs", nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @command_vpc.view
    end

  end

  describe "#check_managemeent_data" do

    it "displays human readable string indicating that the check failed cause there is no externalid" do
      expect(@shellout).to receive(:cli).with(c_describe_vpcs, nil).ordered.and_return(r_vpcs_no_externalid)
      expect(@textout).to receive(:puts).with(r_check_management_data_fail_externalid).ordered
      @command_vpc.check_management_data
    end

    it "displays human readable string indicating that the check has warning cause there is no name" do
      expect(@shellout).to receive(:cli).with(c_describe_vpcs, nil).ordered.and_return(r_vpcs_no_name)
      expect(@textout).to receive(:puts).with(r_check_management_data_warning_name).ordered
      @command_vpc.check_management_data
    end

  end

  describe "#declare" do
    context "in which the target vpc has been created" do
      it "does not attempt to create it, instead informs caller of it existence" do
        expect(@shellout).to receive(:cli).with(c_describe_vpcs, nil).and_return(r_vpcs)
        expect(@textout).to receive(:puts).with(no_action_vpc_exists)
        expect(@textout).to receive(:puts).with(0)
        @command_vpc.declare(p_cidr,p_externalid)
      end
    end

    context "in which the target vpc has NOT been created" do
      it "then creates it" do
        expect(@shellout).to receive(:cli).with(c_describe_vpcs, nil).and_return(r_vpcs_no_externalid)
        expect(@shellout).to receive(:cli).with(c_create_vpc, nil).and_return(r_vpc_available)
        expect(@shellout).to receive(:cli).with(c_create_tags, nil).and_return('')
        expect(@shellout).to receive(:cli).with(c_create_tags_Name, nil).and_return('')
        expect(@textout).to receive(:puts).with(vpc_created)
        expect(@textout).to receive(:puts).with(0)
        @command_vpc.declare(p_cidr,p_externalid)
      end
    end

    it "declare subnet and wait through pending state" do
      expect(@shellout).to receive(:cli).with(anything(), anything()).and_return(r_vpcs_no_externalid, '','', r_vpc_pending, r_vpc_available)
      expect(@textout).to receive(:puts).with(vpc_created)
      expect(@textout).to receive(:puts).with(0)
      @command_vpc.declare(p_cidr,p_externalid)
    end
  end

  describe "#view_peering" do
    it "display peering information in json" do
      aws_statement="aws --output json --region #{p_region} ec2 describe-vpc-peering-connections"
      expect(@shellout).to receive(:cli).with(aws_statement, nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @command_vpc.view_peering
    end
  end

end
