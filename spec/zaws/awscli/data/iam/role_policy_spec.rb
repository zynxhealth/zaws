require 'spec_helper'

describe ZAWS::AWSCLI::Data::IAM do
  # var_ - Version A. awscli 1.2.13 Return
  # vap_ - Version A. awscli 1.2.13 Parameter 
  # vac_ - Version A. awscli 1.2.13 Command 

  let(:vap_instance_id_exists) { <<-eos
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

  let(:var_list_instance_ids) {"i-abcdefg1\ni-abcdefg2"}

  before(:each) {
	@textout=double('outout')
    @shellout=double('ZAWS::Helper::Shell')
    @data_iam = ZAWS::AWSCLI::Data::IAM::RolePolicy.new(@shellout,nil) 
  }

  describe "#resource_instance_ids" do
    context "in which the role policy has resources with instance ids" do
	  it "returns instance ids as list of strings" do
         @data_iam.load(nil,vap_instance_id_exists,nil)
         expect(@data_iam.resource_instance_ids()).to eq(var_list_instance_ids)
	  end
	end

	context "in which the role policy has resources has no instance ids" do
	
	end
  end

end




