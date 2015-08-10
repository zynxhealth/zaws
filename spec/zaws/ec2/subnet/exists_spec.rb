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
    @command_subnet.aws=ZAWS::AWS.new(@shellout,ZAWS::AWSCLI.new(@shellout))
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
  end

end


