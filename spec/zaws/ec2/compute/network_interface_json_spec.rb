require 'spec_helper'

describe ZAWS::EC2Services::Compute do 

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

	textout=double('outout')
	shellout=double('ZAWS::Helper::Shell')
    expect(shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=my_vpc_id'",nil).and_return(subnets)
    expect(shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 describe-security-groups --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=my_security_group_name'",nil).and_return(sgroups)
	aws=ZAWS::AWS.new(shellout)
	bdm = aws.ec2.compute.network_interface_json('us-west-1',nil,'my_vpc_id','10.0.0.6','my_security_group_name')
	expect(bdm).to eq('[{"Groups":["sg-903004f8"],"PrivateIpAddress":"10.0.0.6","DeviceIndex":"0","SubnetId":"subnet-YYYYYY"}]')

  end

end



