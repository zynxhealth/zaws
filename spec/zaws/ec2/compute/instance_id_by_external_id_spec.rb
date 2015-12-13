require 'spec_helper'

describe ZAWS::Services::EC2::Compute do

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

end


