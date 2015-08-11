require 'spec_helper'

describe ZAWS::EC2Services::Compute do 

  before(:each) {
	@textout=double('outout')
    @shellout=double('ZAWS::Helper::Shell')
    @aws=ZAWS::AWS.new(@shellout,ZAWS::AWSCLI.new(@shellout))
  }
  describe "#instance_ping?" do
	it "determines an instance is reachable over the network with ping" do

	  comline ='ping -q -c 2 0.0.0.0'
	  times_called = 0
	  @shellout.stub(:cli).with(comline,nil).and_return do
		  times_called += 1
		  raise Mixlib::ShellOut::ShellCommandFailed if times_called == 2
	  end
	  @aws.ec2.compute.instance_ping?('0.0.0.0',10,1)

	end

	it "determines an instance is not reachable over the network with ping" do

	  comline ='ping -q -c 2 0.0.0.0'
	  times_called = 0
	  @shellout.stub(:cli).with(comline,nil).and_return do
		  times_called += 1
		  raise Mixlib::ShellOut::ShellCommandFailed if times_called < 4
	  end
	  expect {@aws.ec2.compute.instance_ping?('0.0.0.0',2,1)}.to raise_error(StandardError, 'Timeout before instance responded to ping.')
	end
  end

  describe "#nosdcheck" do
	it "sets no source/destination check for instances intended to be NAT instances" do
	  nosd_check_result  = <<-eos
		{ "return":"true" }
	  eos
	  expect(@shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 modify-instance-attribute --instance-id=id-X --no-source-dest-check",nil).and_return(nosd_check_result)
	  @aws.ec2.compute.nosdcheck('us-west-1','id-X')
	end
  end

  describe "#network_interface_json" do
	it "provides a network interface structure" do

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

	  sgroups = <<-eos
		{
			"SecurityGroups": [
				{
					"Description": "My security group",
					"GroupName": "my_security_group_name",
					"OwnerId": "123456789012",
					"GroupId": "sg-903004f8"
				}
			]
		}
	  eos

	  expect(@shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=my_vpc_id'",nil).and_return(subnets)
	  expect(@shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 describe-security-groups --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=my_security_group_name'",nil).and_return(sgroups)
	  bdm = @aws.ec2.compute.network_interface_json('us-west-1',nil,'my_vpc_id','10.0.0.6','my_security_group_name')
	  expect(bdm).to eq('[{"Groups":["sg-903004f8"],"PrivateIpAddress":"10.0.0.6","DeviceIndex":0,"SubnetId":"subnet-YYYYYY"}]')

	end

  end
end



