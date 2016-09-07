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
    it "Get security groups in a human readable table." do
      desc_sec_grps = ZAWS::External::AWSCLI::Generators::API::EC2::DescribeSecurityGroups.new
      aws_command = ZAWS::External::AWSCLI::Generators::API::AWS::AWS.new
      aws_command = aws_command.with_output(@var_output_table).with_region(@var_region).with_subcommand(desc_sec_grps)
      expect(@shellout).to receive(:cli).with(aws_command.get_command, nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @aws.ec2.security_group.view('us-west-1', 'table', @textout)
    end

    it "Get security groups in JSON form" do
      desc_sec_grps = ZAWS::External::AWSCLI::Generators::API::EC2::DescribeSecurityGroups.new
      aws_command = ZAWS::External::AWSCLI::Generators::API::AWS::AWS.new
      aws_command = aws_command.with_output(@var_output_json).with_region(@var_region).with_subcommand(desc_sec_grps)
      expect(@shellout).to receive(:cli).with(aws_command.get_command, nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @aws.ec2.security_group.view('us-west-1', 'json', @textout)
    end

    it "Get security groups from specified vpcid" do
      filter=ZAWS::External::AWSCLI::Generators::API::EC2::Filter.new
      desc_sec_grps = ZAWS::External::AWSCLI::Generators::API::EC2::DescribeSecurityGroups.new
      aws_command = ZAWS::External::AWSCLI::Generators::API::AWS::AWS.new
      desc_sec_grps = desc_sec_grps.filter(filter.vpc_id(@var_vpc_id))
      aws_command = aws_command.with_output(@var_output_json).with_region(@var_region).with_subcommand(desc_sec_grps)
      expect(@shellout).to receive(:cli).with(aws_command.get_command, nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @aws.ec2.security_group.view('us-west-1', 'json', @textout,nil,@var_vpc_id)
    end

    it "Get all security groups that are not actively associated to an instance" do

      security_groups = ZAWS::External::AWSCLI::Generators::Result::EC2::SecurityGroups.new
      security_groups = security_groups.group_name(0, "my_group_name").group_id(0, "sg-C2345678")
      instances = ZAWS::External::AWSCLI::Generators::Result::EC2::Instances.new
      net_interfaces= ZAWS::External::AWSCLI::Generators::Result::EC2::NetworkInterfaces.new
      net_interfaces=net_interfaces.network_interface_id(0,"eni-12345678").groups(0,security_groups)
      instances = instances.instance_id(0,"i-12345678")
      instances = instances.security_groups(0,security_groups)
      instances = instances.network_interfaces(0,net_interfaces)

      desc_instances = ZAWS::External::AWSCLI::Generators::API::EC2::DescribeInstances.new
      aws_command = ZAWS::External::AWSCLI::Generators::API::AWS::AWS.new
      aws_command = aws_command.with_output("json").with_region("us-west-1").with_subcommand(desc_instances)

      expect(@shellout).to receive(:cli).with(aws_command.get_command, nil).and_return(instances.get_json)

      security_groups = ZAWS::External::AWSCLI::Generators::Result::EC2::SecurityGroups.new
      security_groups = security_groups.group_name(0, "my_group_name").vpc_id(0, "vpc-12345678").owner_id(0, "123456789012").group_id(0, "sg-C2345678")
      security_groups = security_groups.group_name(1, "default").vpc_id(1, "vpc-1f6bb57a").owner_id(1, "123456789012").group_id(1, "sg-B2345678")
      security_groups = security_groups.group_name(2, "my_unused_group").vpc_id(2, "vpc-12345678").owner_id(2, "123456789012").group_id(2, "sg-A2345678")

      desc_sec_grps = ZAWS::External::AWSCLI::Generators::API::EC2::DescribeSecurityGroups.new
      aws_command = ZAWS::External::AWSCLI::Generators::API::AWS::AWS.new
      aws_command = aws_command.with_output(@var_output_json).with_region(@var_region).with_subcommand(desc_sec_grps)

      expect(@shellout).to receive(:cli).with(aws_command.get_command, nil).ordered.and_return(security_groups.get_json)

      expect(@textout).to receive(:puts).with("default\nmy_unused_group").ordered
      @aws.ec2.security_group.view('us-west-1', 'json', @textout,nil,nil,nil,nil,nil,nil,nil,nil,true)

    end


  end

  describe "#id_by_name" do
    it "security group id by group name" do

      security_groups = ZAWS::External::AWSCLI::Generators::Result::EC2::SecurityGroups.new
      security_groups = security_groups.group_name(0, @var_sec_group_name).group_id(0, @var_security_group_id)

      filter=ZAWS::External::AWSCLI::Generators::API::EC2::Filter.new
      desc_sec_grps = ZAWS::External::AWSCLI::Generators::API::EC2::DescribeSecurityGroups.new
      aws_command = ZAWS::External::AWSCLI::Generators::API::AWS::AWS.new
      desc_sec_grps = desc_sec_grps.filter(filter.vpc_id(@var_vpc_id).group_name(@var_sec_group_name))
      aws_command = aws_command.with_output(@var_output_json).with_region(@var_region).with_subcommand(desc_sec_grps)

      expect(@shellout).to receive(:cli).with(aws_command.get_command, nil).and_return(security_groups.get_json)
      expect(@textout).to receive(:puts).with(@var_security_group_id)
      @aws.ec2.security_group.id_by_name(@var_region, @textout, nil, @var_vpc_id, @var_sec_group_name)
    end
  end

  describe "#filter_groups_by_instances" do
    it 'filters out groups with security group ids used on an instance provided' do

      security_groups = ZAWS::External::AWSCLI::Generators::Result::EC2::SecurityGroups.new
      security_groups = security_groups.group_name(0, "my_group_name").vpc_id(0, "vpc-12345678").owner_id(0, "123456789012").group_id(0, "sg-C2345678")
      security_groups = security_groups.group_name(1, "default").vpc_id(1, "vpc-1f6bb57a").owner_id(1, "123456789012").group_id(1, "sg-B2345678")
      security_groups = security_groups.group_name(2, "my_unused_group").vpc_id(2, "vpc-12345678").owner_id(2, "123456789012").group_id(2, "sg-A2345678")
      security_groups_raw = security_groups.get_json

      security_groups = ZAWS::External::AWSCLI::Generators::Result::EC2::SecurityGroups.new
      security_groups = security_groups.group_name(0, "my_group_name").group_id(0, "sg-C2345678")
      instances = ZAWS::External::AWSCLI::Generators::Result::EC2::Instances.new
      net_interfaces= ZAWS::External::AWSCLI::Generators::Result::EC2::NetworkInterfaces.new
      net_interfaces=net_interfaces.network_interface_id(0,"eni-1234568").groups(0,security_groups)
      instances = instances.instance_id(0,"i-12345678")
      instances = instances.security_groups(0,security_groups)
      instances = instances.network_interfaces(0,net_interfaces)
      instances_raw=instances.get_json

      security_groups = ZAWS::External::AWSCLI::Generators::Result::EC2::SecurityGroups.new
      security_groups = security_groups.group_name(0, "default").vpc_id(0, "vpc-1f6bb57a").owner_id(0, "123456789012").group_id(0, "sg-B2345678")
      security_groups = security_groups.group_name(1, "my_unused_group").vpc_id(1, "vpc-12345678").owner_id(1, "123456789012").group_id(1, "sg-A2345678")
      security_groups_filtered =security_groups.get_json.gsub(/\s+/,'')

      expect(@aws.ec2.security_group.filter_groups_by_instances(security_groups_raw, instances_raw)).to eq(security_groups_filtered)

    end
  end

end
   
