require 'spec_helper'

describe ZAWS::EC2Services::Compute do 

  before(:each) {
	@textout=double('outout')
    @shellout=double('ZAWS::Helper::Shell')
    @aws=ZAWS::AWS.new(@shellout,ZAWS::AWSCLI.new(@shellout))
  }

  describe "#instance_id_by_external_id" do
	it "provides an instance id when you give it a external id" do

	  compute_instances = <<-eos
	   {  "Reservations": [ 
		 { "Instances" : [ {"InstanceId": "i-XXXXXXX","Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } 
		 ] } 
	  eos

	  expect(@shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'",nil).and_return(compute_instances)
	  instanceid = @aws.ec2.compute.instance_id_by_external_id('us-west-1','my_instance','my_vpc_id',nil,nil)
	  expect(instanceid).to eq("i-XXXXXXX")
	end
  end

  describe "#tag_resource" do 

	it "tags an instance when created" do
	  tag_created = <<-eos
		{ "return":"true" }
	  eos
	  expect(@shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 create-tags --resources id-X --tags Key=externalid,Value=extername",nil).and_return(tag_created)
	  expect(@shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 create-tags --resources id-X --tags Key=Name,Value=extername",nil).and_return(tag_created)
	  @aws.ec2.compute.tag_resource('us-west-1','id-X','extername')
	end

  end


end


