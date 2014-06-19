require 'spec_helper'

describe ZAWS::EC2Services::Compute do 

  it "provides a block device mapping overriding the root size" do

	images = <<-eos
      { "Images": [
		 { "RootDeviceName": "/dev/sda1", 
		   "BlockDeviceMappings": [
		    { "DeviceName": "/dev/sda1",
			  "Ebs": {
			    "DeleteOnTermination": true,
			    "SnapshotId": "snap-XXX",
				"VolumeSize": 7,
				"VolumeType": "standard" } } ] } ] }
	eos

	textout=double('outout')
	shellout=double('ZAWS::Helper::Shell')
	expect(shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 describe-images --owner me --image-ids X",nil).and_return(images)
	aws=ZAWS::AWS.new(shellout)
	bdm = aws.ec2.compute.block_device_mapping('us-west-1','me',nil,70,'X')
	expect(bdm).to eq('[{"DeviceName":"/dev/sda1","Ebs":{"DeleteOnTermination":true,"SnapshotId":"snap-XXX","VolumeSize":70,"VolumeType":"standard"}}]')

  end

end



