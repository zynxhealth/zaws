require 'spec_helper'

describe ZAWS::EC2Services::Subnet do
  
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

	shellout=double('ZAWS::Helper::Shell')
	expect(shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=vpc-XXXXXX' 'Name=cidr,Values=10.0.0.0/24'",nil).and_return(subnets_10_0_0_0_24)
	expect(shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=vpc-XXXXXX' 'Name=cidr,Values=10.0.1.0/24'",nil).and_return(subnets_10_0_1_0_24)
	aws=ZAWS::AWS.new(shellout)
	expect(aws.ec2.subnet.id_array_by_cidrblock_array('us-west-1',nil,nil,'vpc-XXXXXX',["10.0.0.0/24","10.0.1.0/24"])).to eql(["subnet-YYYYYYYY","subnet-ZZZZZZZZ"])

  end

end


