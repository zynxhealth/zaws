require 'spec_helper'

describe ZAWS::EC2 do

  it "declare subnet " do

    empty_subnets = <<-eos
	  {   "Subnets": []  }
	eos

    create_subnet_return = <<-eos
      { "Subnet": { "State": "pending" } }        
	eos
    
	# example output for: aws ec2 escribe-subnets
	describe_subnets = <<-eos
	  { "Subnets": [  {  "State": "available"  }  ] }
	eos

	textout=double('outout')
	shellout=double('ZAWS::Helper::Shell')
    shellout.stub(:cli).with(anything(),anything()).and_return(empty_subnets,create_subnet_return,describe_subnets)
	expect(textout).to receive(:puts).with('Subnet created.')
	aws=ZAWS::AWS.new(shellout)
	aws.ec2.subnet.declare('us-west-1','vpc-XXXXXX','10.0.0.0/24','us-west-1a',30,textout)

  end

end


