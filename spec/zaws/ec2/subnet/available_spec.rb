require 'spec_helper'

describe ZAWS::EC2 do

  it "determine subnet is available by return json from create-subnet" do

	# example output for: aws ec2 escribe-subnets
	subnet = <<-eos
	  {   "Subnet": {
			   "State": "available"
		   }
	 }
	eos

	shellout=double('ZAWS::Helper::Shell')
	aws=ZAWS::AWS.new(shellout)
	expect(aws.ec2.subnet.available(subnet,nil)).to be true
  end

end


