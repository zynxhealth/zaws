require 'spec_helper'

describe ZAWS::EC2Services::SecurityGroup do
 
  before(:each) {
	@textout=double('outout')
    @shellout=double('ZAWS::Helper::Shell')
    @aws=ZAWS::AWS.new(@shellout,ZAWS::AWSCLI.new(@shellout))
  }

  describe "#id_by_name" do
	it "security group id by group name" do

	  sgroups = <<-eos
		{
			"SecurityGroups": [
				{
					"Description": "My security group",
					"GroupName": "my_security_group_name",
					"OwnerId": "123456789012",
					"GroupId": "sg-abcd1234"
				}
			]
		}
	  eos

	  expect(@shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 describe-security-groups --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=my_security_group_name'",nil).and_return(sgroups)
	  expect(@textout).to receive(:puts).with('sg-abcd1234')
	  @aws.ec2.security_group.id_by_name('us-west-1',@textout,nil,'my_vpc_id','my_security_group_name')
	end
  end

  describe "#filter_groups_by_instances" do
	it 'security group id by group name' do

	  security_groups_raw = <<-eos
		  { "SecurityGroups": [
			  {
				  "GroupName": "my_group_name",
				  "VpcId": "vpc-12345678",
				  "OwnerId": "123456789012",
				  "GroupId": "sg-C2345678"
			  },
			  {
				  "GroupName": "default",
				  "VpcId": "vpc-1f6bb57a",
				  "OwnerId": "939117536548",
				  "GroupId": "sg-B2345678"
			  },
			  {
				  "GroupName": "my_unused_group",
				  "VpcId": "vpc-12345678",
				  "OwnerId": "123456789012",
				  "GroupId": "sg-A2345678"
			  }
		  ] }
	  eos

	  instances_raw = <<-eos
				 { "Reservations": [
				 {   "Instances": [
						 {   "InstanceId": "i-12345678",
							 "SecurityGroups": [
								 {
									 "GroupName": "my_group_name",
									 "GroupId": "sg-C2345678"
								 }
							 ],
							 "NetworkInterfaces": [
								 {
									 "NetworkInterfaceId": "eni-12345678",
									 "Groups": [
										 {
											 "GroupName": "my_group_name",
											 "GroupId": "sg-C2345678"
										 }
									 ]
								 }
							 ]
						 }
				 ] }
		   ] }
	  eos

	  security_groups_filtered = '{"SecurityGroups":[{"GroupName":"default","VpcId":"vpc-1f6bb57a","OwnerId":"939117536548","GroupId":"sg-B2345678"},{"GroupName":"my_unused_group","VpcId":"vpc-12345678","OwnerId":"123456789012","GroupId":"sg-A2345678"}]}'

	  expect(@aws.ec2.security_group.filter_groups_by_instances(security_groups_raw,instances_raw)).to eq(security_groups_filtered)

	end
  end

end
   
