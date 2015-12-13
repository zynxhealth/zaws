require 'spec_helper'

describe ZAWS::Services::IAM::Role do
  # var_ - Version A. awscli 1.2.13 Return
  # vap_ - Version A. awscli 1.2.13 Parameter 
  # vac_ - Version A. awscli 1.2.13 Command 
  
  let(:vap_region) {"us-west-1"}
  let(:vap_role) {"my_role"}
  let(:vap_policy) {"my_policy"}

  let(:options) { {:region => vap_region,:viewtype => 'json'}}


  before(:each) {
	@textout=double('outout')
    @shellout=double('ZAWS::Helper::Shell')
	@command_iam = ZAWS::Command::IAM.new([],options,{});
	@aws=ZAWS::AWS.new(@shellout,ZAWS::AWSCLI.new(@shellout))
    @command_iam.aws=@aws
	@command_iam.out=@textout
	@command_iam.print_exit_code = true
  }

  describe "#view_role_policy" do
	it "view role policy" do
	  expect(@shellout).to receive(:cli).with("aws --output json iam get-role-policy --role-name #{vap_role} --policy-name #{vap_policy}",nil).ordered.and_return('test output')
	  expect(@textout).to receive(:puts).with('test output').ordered
	  @command_iam.view_role_policy(vap_role,vap_policy)
	end
  end

end


