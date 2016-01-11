require 'spec_helper'

describe ZAWS::Services::EC2::Compute do

  volumes = <<-eos
	{ "VolumeId": "vol-1234abcd" }
  eos

  attach_volume = <<-eos
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


  before(:each) {
    @textout=double('outout')
    @shellout=double('ZAWS::Helper::Shell')
    @aws=ZAWS::AWS.new(@shellout, ZAWS::AWSCLI.new(@shellout))
  }

  describe "#add_volume" do
    it "creates, tags, and attachs a volume" do
      expect(@shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 create-volume --availability-zone us-west-1a --size 70", nil).and_return(volumes)
      expect(@shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 create-tags --resources vol-1234abcd --tags Key=externalid,Value=extername", nil).and_return(tag_created)
      expect(@shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 create-tags --resources vol-1234abcd --tags Key=Name,Value=extername", nil).and_return(tag_created)
      expect(@shellout).to receive(:cli).with('ping -q -c 2 0.0.0.0', nil).and_return(true)
      expect(@shellout).to receive(:cli).with("aws --output json ec2 attach-volume --region us-west-1 --volume-id vol-1234abcd --instance-id id-X --device /dev/sda", nil).and_return(attach_volume)
      bdm = @aws.ec2.compute.add_volume('us-west-1', 'id-X', 'extername', '0.0.0.0', '/dev/sda', 'us-west-1a', 70, nil)
    end
  end

  describe "#block_device_mapping" do
    it "provides a block device mapping overriding the root size" do
      expect(@shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 describe-images --owner me --image-ids X", nil).and_return(images)
      bdm = @aws.ec2.compute.block_device_mapping('us-west-1', 'me', nil, 70, 'X')
      expect(bdm).to eq('[{"DeviceName":"/dev/sda1","Ebs":{"DeleteOnTermination":true,"SnapshotId":"snap-XXX","VolumeSize":70,"VolumeType":"standard"}}]')
    end
  end

end



