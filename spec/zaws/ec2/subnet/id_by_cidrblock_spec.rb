require 'spec_helper'

describe ZAWS::EC2 do

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

	textout=double('outout')
	shellout=double('ZAWS::Helper::Shell')
	expect(shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=vpc-XXXXXX' 'Name=cidr,Values=10.0.0.0/24'",nil).and_return(subnets)
	expect(textout).to receive(:puts).with('subnet-YYYYYY')
	aws=ZAWS::AWS.new(shellout)
	aws.ec2.subnet.id_by_cidrblock('us-west-1',textout,nil,'vpc-XXXXXX','10.0.0.0/24')

  end

end


