require 'spec_helper'

describe ZAWS::Services::EC2::SecurityGroup do

  before(:each) {
    @textout=double('outout')
    @shellout=double('ZAWS::Helper::Shell')
    @aws=ZAWS::AWS.new(@shellout, ZAWS::AWSCLI.new(@shellout,true))

    @var_security_group_id="sg-abcd1234"
    @var_output_json="json"
    @var_output_table="table"
    @var_region="us-west-1"
    @var_vpc_id="my_vpc_id"
    @var_sec_group_name="my_security_group_name"
  }

  describe "#view" do

    it "Get route table in a human readable table." do
      desc_route_tbls = ZAWS::External::AWSCLI::Generators::API::EC2::DescribeRouteTables.new
      aws_command = ZAWS::External::AWSCLI::Generators::API::AWS::AWS.new
      aws_command = aws_command.with_output(@var_output_table).with_region(@var_region).with_subcommand(desc_route_tbls)
      expect(@shellout).to receive(:cli).with(aws_command.get_command, nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @aws.ec2.security_group.view('us-west-1', 'table', @textout)
    end

    it "Get route table in JSON form" do
      desc_route_tbls = ZAWS::External::AWSCLI::Generators::API::EC2::DescribeRouteTables.new
      aws_command = ZAWS::External::AWSCLI::Generators::API::AWS::AWS.new
      aws_command = aws_command.with_output(@var_output_json).with_region(@var_region).with_subcommand(desc_route_tbls)
      expect(@shellout).to receive(:cli).with(aws_command.get_command, nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @aws.ec2.security_group.view('us-west-1', 'json', @textout)
    end

    it "Get route table from specified vpcid" do
      filter=ZAWS::External::AWSCLI::Generators::API::EC2::Filter.new
      desc_route_tbls = ZAWS::External::AWSCLI::Generators::API::EC2::DescribeRouteTables.new
      aws_command = ZAWS::External::AWSCLI::Generators::API::AWS::AWS.new
      desc_route_tbls = desc_route_tbls.filter(filter.vpc_id(@var_vpc_id))
      aws_command = aws_command.with_output(@var_output_json).with_region(@var_region).with_subcommand(desc_route_tbls)
      expect(@shellout).to receive(:cli).with(aws_command.get_command, nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @aws.ec2.security_group.view('us-west-1', 'json', @textout,nil,@var_vpc_id)
    end

  end

end

