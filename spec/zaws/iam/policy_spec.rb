require 'spec_helper'

describe ZAWS::Services::IAM::Policy do
  # var_ - Version A. awscli 1.2.13 Return
  # vap_ - Version A. awscli 1.2.13 Parameter 
  # vac_ - Version A. awscli 1.2.13 Command 
  
  let(:vap_region) {"us-west-1"}
  let(:vap_role) {"my_role"}
  let(:vap_policy) {"my_policy1"}

  let(:vap_policy_arn) {"arn:aws:iam::123456789abc:policy/#{vap_policy}"}
  let(:vap_policy_version) {"v2"}

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
					"arn:aws:ec2:us-east-1:123456789012:instance/i-88b83d72",
					"arn:aws:ec2:us-east-1:123456789012:instance/i-e1f62836"
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

  let(:options) { {:region => vap_region,:viewtype => 'json'}}


  before(:each) {
	@textout=double('outout')
    @shellout=double('ZAWS::Helper::Shell')
	@command_iam = ZAWS::Command::IAM.new([],options,{});
	@aws=ZAWS::AWS.new(@shellout,ZAWS::AWSCLI.new(@shellout,true))
    @command_iam.aws=@aws
	@command_iam.out=@textout
	@command_iam.print_exit_code = true
  }

  describe "#view_default_policy_version" do
	it "view default policy version" do
	  expect(@shellout).to receive(:cli).with("aws --output json iam get-policy --policy-arn #{vap_policy_arn}",nil).ordered.and_return(var_policy_meta_data)
	  expect(@shellout).to receive(:cli).with("aws --output json iam get-policy-version --policy-arn #{vap_policy_arn} --version-id #{vap_policy_version}",nil).ordered.and_return(var_policy_version_doc)
	  expect(@textout).to receive(:puts).with(var_policy_version_doc).ordered
	  @command_iam.view_default_policy_version(vap_policy_arn)
	end
  end

end




