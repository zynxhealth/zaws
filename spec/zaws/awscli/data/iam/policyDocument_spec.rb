require 'spec_helper'

describe ZAWS::AWSCLI::Data::IAM do
  # var_ - Version A. awscli 1.2.13 Return
  # vap_ - Version A. awscli 1.2.13 Parameter 
  # vac_ - Version A. awscli 1.2.13 Command 

  let(:vap_policy_document_instance_ids_exist) { <<-eos
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
					  "arn:aws:ec2:us-east-1:123456789abc:instance/i-abcdefg1",
					  "arn:aws:ec2:us-east-1:123456789abc:instance/i-abcdefg2"
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

  let(:var_list_instance_ids) {"i-abcdefg1\ni-abcdefg2"}

  before(:each) {
	@textout=double('outout')
    @shellout=double('ZAWS::Helper::Shell')
    @data_iam = ZAWS::AWSCLI::Data::IAM::PolicyDocument.new(@shellout,nil) 
  }

  describe "#resource_instance_ids" do
    context "in which the policy document has resources with instance ids" do
	  it "returns instance ids as list of strings" do
         @data_iam.load(nil,vap_policy_document_instance_ids_exist,nil)
         expect(@data_iam.resource_instance_ids()).to eq(var_list_instance_ids)
	  end
	end
  end
end




