require 'spec_helper'

describe ZAWS::Services::EC2::Compute do

  let(:vap_region) { "us-west-1" }
  let(:vap_role) { "my_role" }
  let(:vap_policy) { "my_policy" }

  let(:vap_my_instance_id1) { "i-abcdefg1" }
  let(:vap_my_instance_name1) { "my-name1" }
  let(:vap_my_instance_id2) { "i-abcdefg2" }
  let(:vap_my_instance_name2) { "my-name2" }
  let(:vap_my_instance_id3) { "i-abcdefg3" }
  let(:vap_my_instance_name3) { "my-name3" }

  let(:vap_policy_arn) { "arn:aws:iam::123456789abc:policy/#{vap_policy}" }
  let(:vap_policy_version) { "v2" }

  let(:var_policy_doc) { <<-eos
    {
		"Version": "2012-10-17",
		"Statement": [
			{
				"Action": [
					"ec2:StartInstances",
					"ec2:StopInstances",
					"ec2:CreateTags"
				],
				"Resource": [
					"arn:aws:ec2:us-east-1:123456789abc:instance/#{vap_my_instance_id1}",
					"arn:aws:ec2:us-east-1:123456789abc:instance/#{vap_my_instance_id2}"
				],
				"Effect": "Allow"
			},
			{
				"Action": [
					"iam:GetPolicy",
					"iam:GetPolicyVersion"
				],
				"Resource": [
					"*"
				],
				"Effect": "Allow"
			}
		]
	}
  eos
  }

  let(:var_policy_version_doc) { <<-eos
  {
    "PolicyVersion": {
        "CreateDate": "2015-09-08T06:14:59Z",
        "VersionId": "v2",
        "Document": #{var_policy_doc},
        "IsDefaultVersion": true
    }
  }
  eos
  }

  let(:var_policy_meta_data) { <<-eos
	{
		"Policy": {
			"PolicyName": "#{vap_policy}",
			"CreateDate": "2015-09-08T05:21:54Z",
			"AttachmentCount": 1,
			"IsAttachable": true,
			"PolicyId": "123456789012345678901",
			"DefaultVersionId": "#{vap_policy_version}",
			"Path": "/",
			"Arn": "#{vap_policy_arn}",
			"UpdateDate": "2015-09-08T06:14:59Z"
		}
	} 
  eos
  }


  let(:options) { {:region => vap_region, :viewtype => 'json'} }
  let(:options_policy_arn) { {:region => vap_region,
                              :viewtype => 'json',
                              :policy_arn => vap_policy_arn,
                              :verbose => nil} }

  let(:options_start_name) { {:region => vap_region,
                              :name => vap_my_instance_name1,
                              :verbose => nil,
                              :skipruncheck => true} }

  let(:options_stop_name) { {:region => vap_region,
                             :name => vap_my_instance_name2,
                             :verbose => nil,
                             :skipruncheck => 0} }

  let(:options_set_interval) { {:region => vap_region,
                                :name => vap_my_instance_name2,
                                :viewtype => 'json',
                                :policy_arn => vap_policy_arn,
                                :verbose => nil,
                                :overridebasetime => 0} }

  let(:options_interval_cron) { {:region => vap_region,
                                 :viewtype => 'json',
                                 :policy_arn => vap_policy_arn,
                                 :verbose => nil,
                                 :overridebasetime => 3601} }

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
						  "arn:aws:ec2:us-east-1:123456789012:instance/#{vap_my_instance_id1}",
					      "arn:aws:ec2:us-east-1:123456789012:instance/#{vap_my_instance_id2}"
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
					"OwnerId": "123456789012",
					"ReservationId": "r-88ef5d66",
					"Groups": [],
					"Instances": [
						{
							"State": {
								"Code": 80,
								"Name": "stopped"
							},
							"InstanceId": "#{vap_my_instance_id1}",
							"Tags": [
								{
									"Value": "#{vap_my_instance_name1}",
									"Key": "Name"
								},
								{
									"Value": "0:7200:test@test.com",
									"Key": "interval"
								}

							],
							"AmiLaunchIndex": 0
						}
					]
				},
				{
					"OwnerId": "123456789012",
					"ReservationId": "r-88ef5d66",
					"Groups": [],
					"Instances": [
						{
							"State": {
								"Code": 80,
								"Name": "running"
							},
							"InstanceId": "#{vap_my_instance_id2}",
							"Tags": [
								{
									"Value": "#{vap_my_instance_name2}",
									"Key": "Name"
								},
								{
									"Value": "0:3600:test@test.com",
									"Key": "interval"
								}
							],
							"AmiLaunchIndex": 0
						}
					]
				},
				{
					"OwnerId": "123456789012",
					"ReservationId": "r-88ef5d66",
					"Groups": [],
					"Instances": [
						{
							"State": {
								"Code": 80,
								"Name": "stopped"
							},
							"InstanceId": "#{vap_my_instance_id3}",
							"Tags": [
								{
									"Value": "#{vap_my_instance_name3}",
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

  let(:vap_list_instance_ids) { "i-abcdefg1\ni-abcdefg2" }
  let(:var_list_instance_names) { "my-name1\nmy-name2" }
  let(:interval_val) { "0:3600:test@test.com" }

  before(:each) {
    @textout=double('outout')
    @shellout=double('ZAWS::Helper::Shell')
    @command_compute = ZAWS::Command::Compute.new([], options, {});
    @aws=ZAWS::AWS.new(@shellout, ZAWS::AWSCLI.new(@shellout,true))
    @command_compute.aws=@aws
    @command_compute.out=@textout
    @command_compute.print_exit_code = true
  }

  describe "#instance_id_by_external_id" do
    it "provides an instance id when you give it a external id" do

      tags = ZAWS::External::AWSCLI::Generators::Result::EC2::Tags.new
      tags = tags.add("externalid", "my_instance")
      instances = ZAWS::External::AWSCLI::Generators::Result::EC2::Instances.new
      instances = instances.instance_id(0, "i-XXXXXXX")
      instances = instances.tags(0, tags)
      compute_instances=instances.get_json

      filter=ZAWS::External::AWSCLI::Commands::EC2::Filter.new
      desc_instances = ZAWS::External::AWSCLI::Commands::EC2::DescribeInstances.new
      aws_command = ZAWS::External::AWSCLI::Commands::AWS.new
      desc_instances = desc_instances.filter(filter.vpc_id("my_vpc_id").tags(tags))
      aws_command = aws_command.output("json").region("us-west-1").subcommand(desc_instances)

      expect(@shellout).to receive(:cli).with(aws_command.get_command, nil).and_return(compute_instances)
      instanceid = @aws.ec2.compute.instance_id_by_external_id('us-west-1', 'my_instance', 'my_vpc_id', nil, nil)
      expect(instanceid).to eq("i-XXXXXXX")
    end
  end

  describe "#tag_resource" do
    it "tags an instance when created" do
      tag_created = <<-eos
		{ "return":"true" }
      eos

      tags = ZAWS::External::AWSCLI::Generators::Result::EC2::Tags.new
      tags = tags.add("externalid", "extername")

      create_tags = ZAWS::External::AWSCLI::Commands::EC2::CreateTags.new
      aws_command = ZAWS::External::AWSCLI::Commands::AWS.new
      create_tags = create_tags.resource("id-X").tags(tags)
      aws_command = aws_command.output("json").region("us-west-1").subcommand(create_tags)

      expect(@shellout).to receive(:cli).with(aws_command.get_command, nil).and_return(tag_created)

      tags = ZAWS::External::AWSCLI::Generators::Result::EC2::Tags.new
      tags = tags.add("Name", "extername")

      create_tags = ZAWS::External::AWSCLI::Commands::EC2::CreateTags.new
      aws_command = ZAWS::External::AWSCLI::Commands::AWS.new
      create_tags = create_tags.resource("id-X").tags(tags)
      aws_command = aws_command.output("json").region("us-west-1").subcommand(create_tags)

      expect(@shellout).to receive(:cli).with(aws_command.get_command, nil).and_return(tag_created)

      @aws.ec2.compute.tag_resource('us-west-1', 'id-X', 'extername')
    end

  end

  describe "#interval_eligible" do
    context "role policy exists" do
      it "lists the names of the instances" do
        @command_compute = ZAWS::Command::Compute.new([], options_policy_arn, {});
        @command_compute.aws=@aws
        @command_compute.out=@textout
        @command_compute.print_exit_code = true
        expect(@shellout).to receive(:cli).with("aws --output json iam get-policy --policy-arn #{vap_policy_arn}", nil).ordered.and_return(var_policy_meta_data)
        expect(@shellout).to receive(:cli).with("aws --output json iam get-policy-version --policy-arn #{vap_policy_arn} --version-id #{vap_policy_version}", nil).ordered.and_return(var_policy_version_doc)
        expect(@shellout).to receive(:cli).with("aws --output json --region #{vap_region} ec2 describe-instances", nil).and_return(var_describe_instance)
        expect(@textout).to receive(:puts).with("my-name1\nmy-name2")
        @command_compute.interval_eligible()
      end
    end
  end

  describe "#start" do
    context "the instance is stopped, the name as been provided and the name exists" do
      it "will start the instance" do
        @command_compute = ZAWS::Command::Compute.new([], options_start_name, {});
        @command_compute.aws=@aws
        @command_compute.out=@textout
        @command_compute.print_exit_code = true
        expect(@shellout).to receive(:cli).with("aws --output json --region #{vap_region} ec2 describe-instances", nil).and_return(var_describe_instance)
        expect(@shellout).to receive(:cli).with("aws --output json --region #{vap_region} ec2 start-instances --instance-ids #{vap_my_instance_id1}", nil).and_return(var_describe_instance)
        expect(@textout).to receive(:puts).with("Instance #{vap_my_instance_name1} started.")
        @command_compute.start()
      end
    end
  end

  describe "#stop" do
    context "the instance is running, the name as been provided and the name exists" do
      it "will stop the instance" do
        @command_compute = ZAWS::Command::Compute.new([], options_stop_name, {});
        @command_compute.aws=@aws
        @command_compute.out=@textout
        @command_compute.print_exit_code = true
        expect(@shellout).to receive(:cli).with("aws --output json --region #{vap_region} ec2 describe-instances", nil).and_return(var_describe_instance)
        expect(@shellout).to receive(:cli).with("aws --output json --region #{vap_region} ec2 stop-instances --instance-ids #{vap_my_instance_id2}", nil).and_return(var_describe_instance)
        expect(@textout).to receive(:puts).with("Instance #{vap_my_instance_name2} stopped.")
        @command_compute.stop()
      end
    end
  end

  describe "#set_interval" do
    context "the instance exists" do
      it "will tag instance with interval" do
        @command_compute = ZAWS::Command::Compute.new([], options_set_interval, {});
        @command_compute.aws=@aws
        @command_compute.out=@textout
        @command_compute.print_exit_code = true
        expect(@shellout).to receive(:cli).with("aws --output json iam get-policy --policy-arn #{vap_policy_arn}", nil).ordered.and_return(var_policy_meta_data)
        expect(@shellout).to receive(:cli).with("aws --output json iam get-policy-version --policy-arn #{vap_policy_arn} --version-id #{vap_policy_version}", nil).ordered.and_return(var_policy_version_doc)
        expect(@shellout).to receive(:cli).with("aws --output json --region #{vap_region} ec2 describe-instances", nil).and_return(var_describe_instance)
        expect(@shellout).to receive(:cli).with("aws --output json --region #{vap_region} ec2 create-tags --resources #{vap_my_instance_id2} --tags Key=interval,Value=#{interval_val}", nil).and_return(var_describe_instance)
        expect(@textout).to receive(:puts).with("Instance #{vap_my_instance_name2} tagged: Key=interval,Value=#{interval_val}")
        @command_compute.set_interval(1, "test@test.com")
      end
    end
  end

  describe "#interval_cron" do
    context "one instance set to start that is stopped, one vice versa, one other" do
      it "will start one, stop one, and nothing one" do
        @command_compute = ZAWS::Command::Compute.new([], options_interval_cron, {});
        @command_compute.aws=@aws
        @command_compute.out=@textout
        @command_compute.print_exit_code = true
        expect(@shellout).to receive(:cli).with("aws --output json iam get-policy --policy-arn #{vap_policy_arn}", nil).ordered.and_return(var_policy_meta_data)
        expect(@shellout).to receive(:cli).with("aws --output json iam get-policy-version --policy-arn #{vap_policy_arn} --version-id #{vap_policy_version}", nil).ordered.and_return(var_policy_version_doc)
        expect(@shellout).to receive(:cli).with("aws --output json --region #{vap_region} ec2 describe-instances", nil).and_return(var_describe_instance)
        expect(@shellout).to receive(:cli).with("aws --output json --region #{vap_region} ec2 start-instances --instance-ids #{vap_my_instance_id1}", nil).and_return(var_describe_instance)
        expect(@shellout).to receive(:cli).with("aws --output json --region #{vap_region} ec2 stop-instances --instance-ids #{vap_my_instance_id2}", nil).and_return(var_describe_instance)
        expect(@textout).to receive(:puts).with("Instance #{vap_my_instance_name1} started.")
        expect(@textout).to receive(:puts).with("Instance #{vap_my_instance_name2} stopped.")
        @command_compute.interval_cron()
      end
    end
  end


end
