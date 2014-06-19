require 'spec_helper'

describe ZAWS::EC2Services::Compute do 

  it "sets no source/destination check for instances intended to be NAT instances" do
	nosd_check_result  = <<-eos
      { "return":"true" }
	eos
	textout=double('outout')
	shellout=double('ZAWS::Helper::Shell')
	expect(shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 modify-instance-attribute --instance-id=id-X --no-source-dest-check",nil).and_return(nosd_check_result)
	aws=ZAWS::AWS.new(shellout)
	aws.ec2.compute.nosdcheck('us-west-1','id-X')
  end

end

