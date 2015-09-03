require 'spec_helper'

describe ZAWS::EC2Services::Compute do 

  let(:vap_region) {"us-west-1"}
  let(:vap_role) {"my_role"}
  let(:vap_policy) {"my_policy"}

  let(:options) { {:region => vap_region,:viewtype => 'json'}}
  let(:options_role_policy) { {:region => vap_region,
							   :viewtype => 'json',
							   :role => vap_role,
							   :policy => vap_policy,
                               :verbose => nil}}

  let(:var_policy) { <<-eos
	  {
		  "RoleName": "testStartStop",
		  "PolicyDocument": {
			  "Version": "2012-10-17",
			  "Statement": [
				  {
					  "Action": [
						  "ec2:StartInstances",
						  "ec2:StopInstances"
					  ],
					  "Resource": [
						  "arn:aws:ec2:us-east-1:939117536548:instance/i-abcdefg1",
					      "arn:aws:ec2:us-east-1:939117536548:instance/i-abcdefg2"
					  ],
					  "Effect": "Allow"
				  }
			  ]
		  },
		  "PolicyName": "testStopStart"
	  }
	  eos
   }

   let(:var_describe_instance) { <<-eos
		{
			"Reservations": [
				{
					"OwnerId": "939117536548",
					"ReservationId": "r-88ef5d66",
					"Groups": [],
					"Instances": [
						{
							"State": {
								"Code": 80,
								"Name": "stopped"
							},
							"InstanceId": "i-abcdefg1",
							"Tags": [
								{
									"Value": "my-name1",
									"Key": "Name"
								}
							],
							"AmiLaunchIndex": 0
						}
					]
				},
				{
					"OwnerId": "939117536548",
					"ReservationId": "r-88ef5d66",
					"Groups": [],
					"Instances": [
						{
							"State": {
								"Code": 80,
								"Name": "stopped"
							},
							"InstanceId": "i-abcdefg2",
							"Tags": [
								{
									"Value": "my-name2",
									"Key": "Name"
								}
							],
							"AmiLaunchIndex": 0
						}
					]
				}

			]
		}	
 	  eos
   }

  let(:vap_list_instance_ids) {"i-abcdefg1\ni-abcdefg2"}
  let(:var_list_instance_names) {"my-name1\nmy-name2"}

 
  before(:each) {
	@textout=double('outout')
    @shellout=double('ZAWS::Helper::Shell')
	@command_compute = ZAWS::Command::Compute.new([],options,{});
	@aws=ZAWS::AWS.new(@shellout,ZAWS::AWSCLI.new(@shellout))
    @command_compute.aws=@aws
	@command_compute.out=@textout
	@command_compute.print_exit_code = true
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

  describe "#interval_eligible" do
    context "role policy exists" do
	  it "lists the names of the instances" do
		 @command_compute = ZAWS::Command::Compute.new([],options_role_policy,{});
		 @command_compute.aws=@aws
		 @command_compute.out=@textout
		 @command_compute.print_exit_code = true
         expect(@shellout).to receive(:cli).with("aws --output json iam get-role-policy --role-name #{vap_role} --policy-name #{vap_policy}",nil).and_return(var_policy)
         expect(@shellout).to receive(:cli).with("aws --output json --region #{vap_region} ec2 describe-instances",nil).and_return(var_describe_instance)
		 expect(@textout).to receive(:puts).with("my-name1\nmy-name2")
		 @command_compute.interval_eligible()
 	  end
	end
  end

end
