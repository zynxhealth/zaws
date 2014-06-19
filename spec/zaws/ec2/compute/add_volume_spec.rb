require 'spec_helper'

describe ZAWS::EC2Services::Compute do 

  it "add volume to instance" do

	volumes = <<-eos
    { "VolumeId": "vol-1234abcd" }
	eos

	attachvolume = <<-eos
    {
       "AttachTime": "YYYY-MM-DDTHH:MM:SS.000Z",
	   "InstanceId": "id-X",
	   "VolumeId": "vol-1234abcd",
	   "State": "attaching",
	   "Device": "/dev/sda"		}
	eos
	
	tag_created = <<-eos
      { "return":"true" }
	eos

	textout=double('outout')
	shellout=double('ZAWS::Helper::Shell')
	expect(shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 create-volume --availability-zone us-west-1a --size 70",nil).and_return(volumes)
	expect(shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 create-tags --resources vol-1234abcd --tags Key=externalid,Value=extername",nil).and_return(tag_created)
	expect(shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 create-tags --resources vol-1234abcd --tags Key=Name,Value=extername",nil).and_return(tag_created)
    expect(shellout).to receive(:cli).with('ping -q -c 2 0.0.0.0',nil).and_return(true)
	expect(shellout).to receive(:cli).with("aws --output json ec2 attach-volume --region us-west-1 --volume-id vol-1234abcd --instance-id id-X --device /dev/sda",nil).and_return(attachvolume)
    aws=ZAWS::AWS.new(shellout)
	bdm = aws.ec2.compute.add_volume('us-west-1','id-X','extername','0.0.0.0','/dev/sda','us-west-1a',70,nil)

  end

end



