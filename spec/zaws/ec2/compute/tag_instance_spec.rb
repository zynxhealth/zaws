require 'spec_helper'

describe ZAWS::EC2Services::Compute do 

  it "tags an instance when created" do
	tag_created = <<-eos
      { "return":"true" }
	eos
	textout=double('outout')
	shellout=double('ZAWS::Helper::Shell')
	expect(shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 create-tags --resources id-X --tags Key=externalid,Value=extername",nil).and_return(tag_created)
	expect(shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 create-tags --resources id-X --tags Key=Name,Value=extername",nil).and_return(tag_created)
	aws=ZAWS::AWS.new(shellout)
	aws.ec2.compute.tag_resource('us-west-1','id-X','extername')
  end

end




