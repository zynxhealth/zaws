require 'spec_helper'

describe ZAWS::EC2Services::Compute do 

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

	textout=double('outout')
	shellout=double('ZAWS::Helper::Shell')
	comline="aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'"
	expect(shellout).to receive(:cli).with(comline,nil).and_return(compute_instances_without,compute_instances)
	aws=ZAWS::AWS.new(shellout)
	aws.ec2.compute.instance_running?('us-west-1','my_vpc_id','my_instance',3,1,nil)

  end

  it "determines an instance is not running" do

    compute_instances_without = <<-eos
	 {  "Reservations": [ 
	   { "Instances" : [ {"InstanceId": "i-XXXXXXX","State": { "Code":0 }, "Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } 
	   ] } 
	eos

	textout=double('outout')
	shellout=double('ZAWS::Helper::Shell')
	comline="aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'"
	expect(shellout).to receive(:cli).with(comline,nil).and_return(compute_instances_without,compute_instances_without)
	aws=ZAWS::AWS.new(shellout)
	expect {aws.ec2.compute.instance_running?('us-west-1','my_vpc_id','my_instance',5,2,nil)}.to raise_error(StandardError, 'Timeout before instance state code set to running(16).')

  end

end


