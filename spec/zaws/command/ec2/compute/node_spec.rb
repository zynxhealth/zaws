require 'spec_helper'

describe ZAWS::Services::EC2::Compute do

  before(:each) {
	@textout=double('outout')
    @shellout=double('ZAWS::Helper::Shell')
    @aws=ZAWS::AWS.new(@shellout,ZAWS::AWSCLI.new(@shellout,true))
  }

  describe "#placement_aggregate" do

	it "creates a placement with a zone value only" do

		  expect(@aws.ec2.compute.placement_aggregate("zone",nil)).to eq("AvailabilityZone=zone")

	end

	it "creates a placement with a tenancy value only" do

		  expect(@aws.ec2.compute.placement_aggregate(nil,"tenancy")).to eq("Tenancy=tenancy")

	end

	it "creates a placement with a zone and a tenancy value " do

		  expect(@aws.ec2.compute.placement_aggregate("zone","tenancy")).to eq("AvailabilityZone=zone,Tenancy=tenancy")

	end
  end

  describe "#instance_running?" do
  it "determines an instance is running" do

    compute_instances_without = <<-eos
	 {  "Reservations": [ 
	   { "Instances" : [ {"InstanceId": "i-XXXXXXX","State": { "Code":0 }, "Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } 
	   ] } 
	eos

	compute_instances = <<-eos
	 {  "Reservations": [ 
	   { "Instances" : [ {"InstanceId": "i-XXXXXXX","State": { "Code":16 }, "Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } 
	   ] } 
	eos

	comline="aws --output json --region us-west-1 ec2 describe-instances --filter \"Name=vpc-id,Values=my_vpc_id\" \"Name=tag:externalid,Values=my_instance\""
	expect(@shellout).to receive(:cli).with(comline,nil).and_return(compute_instances_without,compute_instances)
	@aws.ec2.compute.instance_running?('us-west-1','my_vpc_id','my_instance',3,1,nil)

  end

  it "determines an instance is not running" do

    compute_instances_without = <<-eos
	 {  "Reservations": [ 
	   { "Instances" : [ {"InstanceId": "i-XXXXXXX","State": { "Code":0 }, "Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } 
	   ] } 
	eos

	comline="aws --output json --region us-west-1 ec2 describe-instances --filter \"Name=vpc-id,Values=my_vpc_id\" \"Name=tag:externalid,Values=my_instance\""
	expect(@shellout).to receive(:cli).with(comline,nil).and_return(compute_instances_without,compute_instances_without)
	expect {@aws.ec2.compute.instance_running?('us-west-1','my_vpc_id','my_instance',5,2,nil)}.to raise_error(StandardError, 'Timeout before instance state code set to running(16).')

  end
  end

end


