
require 'spec_helper'

describe ZAWS::EC2 do

  it "view subnets, table view" do
	textout=double('outout')
	shellout=double('ZAWS::Helper::Shell')
    expect(shellout).to receive(:cli).with("aws --output table --region us-west-1 ec2 describe-subnets",nil).ordered.and_return('test output')
    expect(textout).to receive(:puts).with('test output').ordered
	aws=ZAWS::AWS.new(shellout)
	aws.ec2.subnet.view('us-west-1','table',textout)
  end

  it "view subnets, json view" do
	textout=double('outout')
	shellout=double('ZAWS::Helper::Shell')
	expect(shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 describe-subnets",nil).ordered.and_return('test output')
	expect(textout).to receive(:puts).with('test output').ordered
	aws=ZAWS::AWS.new(shellout)
	aws.ec2.subnet.view('us-west-1','json',textout)
  end

  it "view subnets with verbose" do
	textout=double('outout')
	shellout=double('ZAWS::Helper::Shell')
	expect(shellout).to receive(:cli).with("aws --output table --region us-west-1 ec2 describe-subnets",textout).ordered.and_return('test output')
	expect(textout).to receive(:puts).with('test output').ordered
	aws=ZAWS::AWS.new(shellout)
	aws.ec2.subnet.view('us-west-1','table',textout,textout)
  end


end
