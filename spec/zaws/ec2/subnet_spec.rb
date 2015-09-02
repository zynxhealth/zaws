require 'spec_helper'

describe ZAWS::EC2Services::Subnet do
  # var_ - Version A. awscli 1.2.13 Return
  # vap_ - Version A. awscli 1.2.13 Parameter 
  # vac_ - Version A. awscli 1.2.13 Command 

  let(:vap_cidr) { "10.0.0.0/24"}

  let(:vap_vpcid) {"vpc-XXXXXX"}

  let(:vap_region) {"us-west-1"}

  let(:vap_az) {"us-west-1b"}


  let(:vac_describe_subnets) {"aws --output json --region #{vap_region} ec2 describe-subnets --filter 'Name=vpc-id,Values=#{vap_vpcid}' 'Name=cidr,Values=#{vap_cidr}'" }

  let(:var_subnets_exist) { <<-eos
		{   "Subnets": [
			 {
				 "VpcId": "#{vap_vpcid}",
				 "CidrBlock": "#{vap_cidr}",
				 "MapPublicIpOnLaunch": false,
				 "DefaultForAz": false,
				 "State": "available",
				 "SubnetId": "subnet-YYYYYY",
				 "AvailableIpAddressCount": 251
			 }
		 ]
	   }
	  eos
   }

  let(:var_subnets_not_exist) { <<-eos
		{   "Subnets": [ ]   }
	  eos
   }


  let(:vac_create_subnet) {"aws --output json --region #{vap_region} ec2 create-subnet --vpc-id #{vap_vpcid} --cidr-block #{vap_cidr} --availability-zone #{vap_az}"}

  let(:var_subnet_pending) {'{ "Subnet": { "State": "pending" } }'}

  let(:var_subnet_available) {'{ "Subnet": { "State": "available" } }'}
  

  let(:options) { {:region => vap_region, 
				   :verbose => nil,
                   :availabilitytimeout => 30,
                   :nagios => false,
                   :undofile => false}}

  let(:no_action_subnet_exists) {ZAWS::Helper::Output.colorize("No action needed. Subnet exists already.",AWS_consts::COLOR_GREEN)}
  let(:subnet_created)  {ZAWS::Helper::Output.colorize("Subnet created.",AWS_consts::COLOR_YELLOW)}

  before(:each) {
	@textout=double('outout')
    @shellout=double('ZAWS::Helper::Shell')
	@command_subnet = ZAWS::Command::Subnet.new([],options,{});
	@aws=ZAWS::AWS.new(@shellout,ZAWS::AWSCLI.new(@shellout))
    @command_subnet.aws=@aws
	@command_subnet.out=@textout
	@command_subnet.print_exit_code = true
  }

  describe "#exists" do
    context "in which the target subnet has been created" do
	  it "returns true" do
		expect(@shellout).to receive(:cli).with(vac_describe_subnets,nil).and_return(var_subnets_exist)
		expect(@textout).to receive(:puts).with('true')
		@command_subnet.exists(vap_cidr,vap_vpcid)
	  end
	end

    context "in which the target subnet has NOT been created" do
	  it "returns false" do
		expect(@shellout).to receive(:cli).with(vac_describe_subnets,nil).and_return(var_subnets_not_exist)
		expect(@textout).to receive(:puts).with('false')
		@command_subnet.exists(vap_cidr,vap_vpcid)
	  end
    end	
  end

  describe "#declare" do
    context "in which the target subnet has been created" do
	  it "does not attempt to create it, instead informs caller of it existance" do
		expect(@shellout).to receive(:cli).with(vac_describe_subnets,nil).and_return(var_subnets_exist)
		expect(@textout).to receive(:puts).with(no_action_subnet_exists)
		expect(@textout).to receive(:puts).with(0)
		@command_subnet.declare(vap_cidr,vap_az,vap_vpcid)
	  end
    end

    context "in which the target subnet has NOT been created" do
	  it "then creates it" do
		expect(@shellout).to receive(:cli).with(vac_describe_subnets,nil).and_return(var_subnets_not_exist)
		expect(@shellout).to receive(:cli).with(vac_create_subnet,nil).and_return(var_subnet_available)
		expect(@textout).to receive(:puts).with(subnet_created)
		expect(@textout).to receive(:puts).with(0)
		@command_subnet.declare(vap_cidr,vap_az,vap_vpcid)
	  end
	end

	it "declare subnet and wait through pending state" do
	  expect(@shellout).to receive(:cli).with(anything(),anything()).and_return(var_subnets_not_exist,var_subnet_pending,var_subnet_available)
	  expect(@textout).to receive(:puts).with(subnet_created)
      expect(@textout).to receive(:puts).with(0)
	  @command_subnet.declare(vap_cidr,vap_az,vap_vpcid)
	end

  end

  describe "#view" do

	it "view subnets, table view" do
	  expect(@shellout).to receive(:cli).with("aws --output table --region us-west-1 ec2 describe-subnets",nil).ordered.and_return('test output')
	  expect(@textout).to receive(:puts).with('test output').ordered
	  @aws.ec2.subnet.view('us-west-1','table',@textout)
	end

	it "view subnets, json view" do
	  expect(@shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 describe-subnets",nil).ordered.and_return('test output')
	  expect(@textout).to receive(:puts).with('test output').ordered
	  @aws.ec2.subnet.view('us-west-1','json',@textout)
	end

	it "view subnets with verbose" do
	  expect(@shellout).to receive(:cli).with("aws --output table --region us-west-1 ec2 describe-subnets",@textout).ordered.and_return('test output')
	  expect(@textout).to receive(:puts).with('test output').ordered
	  @aws.ec2.subnet.view('us-west-1','table',@textout,@textout)
	end

  end

  describe "#id_array_by_cidrblock_array" do
	
	it "Provides an array of subnet ids if given an array of subnet cidr blocks" do

	  # example output for: aws ec2 escribe-subnets
	  subnets_10_0_0_0_24 = <<-eos
		{   "Subnets": [
			 {
				 "VpcId": "vpc-XXXXXX",
				 "CidrBlock": "10.0.0.0/24",
				 "MapPublicIpOnLaunch": false,
				 "DefaultForAz": false,
				 "State": "available",
				 "SubnetId": "subnet-YYYYYYYY",
				 "AvailableIpAddressCount": 251
			 }
		 ]
	   }
	  eos

	  subnets_10_0_1_0_24 = <<-eos
		{   "Subnets": [
			 {
				 "VpcId": "vpc-XXXXXX",
				 "CidrBlock": "10.0.1.0/24",
				 "MapPublicIpOnLaunch": false,
				 "DefaultForAz": false,
				 "State": "available",
				 "SubnetId": "subnet-ZZZZZZZZ",
				 "AvailableIpAddressCount": 251
			 }
		 ]
	   }
	  eos

	  expect(@shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=vpc-XXXXXX' 'Name=cidr,Values=10.0.0.0/24'",nil).and_return(subnets_10_0_0_0_24)
	  expect(@shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=vpc-XXXXXX' 'Name=cidr,Values=10.0.1.0/24'",nil).and_return(subnets_10_0_1_0_24)
	  expect(@aws.ec2.subnet.id_array_by_cidrblock_array('us-west-1',nil,nil,'vpc-XXXXXX',["10.0.0.0/24","10.0.1.0/24"])).to eql(["subnet-YYYYYYYY","subnet-ZZZZZZZZ"])

	end

  end

  describe "#id_by_ip" do

	it "get subnet id by ip" do

	  # example output for: aws ec2 escribe-subnets
	  subnets = <<-eos
		{   "Subnets": [
			 {
				 "VpcId": "vpc-XXXXXX",
				 "CidrBlock": "10.0.1.0/24",
				 "MapPublicIpOnLaunch": false,
				 "DefaultForAz": false,
				 "State": "available",
				 "SubnetId": "subnet-XXXXXX",
				 "AvailableIpAddressCount": 251
			 },
			 {
				 "VpcId": "vpc-XXXXXX",
				 "CidrBlock": "10.0.0.0/24",
				 "MapPublicIpOnLaunch": false,
				 "DefaultForAz": false,
				 "State": "available",
				 "SubnetId": "subnet-YYYYYY",
				 "AvailableIpAddressCount": 251
			 }
		 ]
	   }
	  eos

	  expect(@shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=vpc-XXXXXX'",nil).and_return(subnets)
	  expect(@textout).to receive(:puts).with('subnet-YYYYYY')
	  @aws.ec2.subnet.id_by_ip('us-west-1',@textout,nil,'vpc-XXXXXX','10.0.0.24')
	end

  end

  describe "#id_by_cidrblock" do

	it "subnet id by cidr block" do

	  # example output for: aws ec2 escribe-subnets
	  subnets = <<-eos
		{   "Subnets": [

			 {
				 "VpcId": "vpc-XXXXXX",
				 "CidrBlock": "10.0.0.0/24",
				 "MapPublicIpOnLaunch": false,
				 "DefaultForAz": false,
				 "State": "available",
				 "SubnetId": "subnet-YYYYYY",
				 "AvailableIpAddressCount": 251
			 }
		 ]
	   }
	  eos

	  expect(@shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=vpc-XXXXXX' 'Name=cidr,Values=10.0.0.0/24'",nil).and_return(subnets)
	  expect(@textout).to receive(:puts).with('subnet-YYYYYY')
	  @aws.ec2.subnet.id_by_cidrblock('us-west-1',@textout,nil,'vpc-XXXXXX','10.0.0.0/24')

	end

  end


end


