require 'spec_helper'

describe ZAWS::Services::EC2::Compute do

  before(:each) {
    @textout=double('outout')
    @shellout=double('ZAWS::Helper::Shell')
    @aws=ZAWS::AWS.new(@shellout, ZAWS::AWSCLI.new(@shellout, false))
  }
  describe "#instance_ping?" do
    it "determines an instance is reachable over the network with ping" do

      comline ='ping -q -c 2 0.0.0.0'
      times_called = 0
      @shellout.stub(:cli).with(comline, nil).and_return do
        times_called += 1
        raise Mixlib::ShellOut::ShellCommandFailed if times_called == 2
      end
      @aws.ec2.compute.instance_ping?('0.0.0.0', 10, 1)

    end

    it "determines an instance is not reachable over the network with ping" do

      comline ='ping -q -c 2 0.0.0.0'
      times_called = 0
      @shellout.stub(:cli).with(comline, nil).and_return do
        times_called += 1
        raise Mixlib::ShellOut::ShellCommandFailed if times_called < 4
      end
      expect { @aws.ec2.compute.instance_ping?('0.0.0.0', 2, 1)
             }.to raise_error(StandardError, 'Timeout before instance responded to ping.')
    end
  end

  describe "#nosdcheck" do
    it "sets no source/destination check for instances intended to be NAT instances" do
      nosd_check_result = '{ "return":"true" }'

      mod_inst_attribute = ZAWS::External::AWSCLI::Commands::EC2::ModifyInstanceAttribute.new
      aws_command = ZAWS::External::AWSCLI::Commands::AWS.new
      mod_inst_attribute = mod_inst_attribute.instance_id("id-X").no_source_dest_check
      aws_command = aws_command.output("json").region("us-west-1").subcommand(mod_inst_attribute)

      expect(@shellout).to receive(:cli).with(aws_command.get_command, nil).and_return(nosd_check_result)
      @aws.ec2.compute.nosdcheck('us-west-1', 'id-X')
    end
  end

  describe "#network_interface_json" do
    it "provides a network interface structure" do

      subnets = ZAWS::External::AWSCLI::Generators::Result::EC2::Subnets.new
      count=0
      [["10.0.1.0/24", "subnet-XXXXXX"], ["10.0.0.0/24", "subnet-YYYYYY"]].each do |x|
        subnets = subnets.vpc_id(count, "vpc-XXXXXX").cidr_block(count, x[0]).map_public_ip_on_launch(count, false)
        subnets = subnets.default_for_az(count, false).state(count, "available").subnet_id(count, x[1])
        subnets = subnets.available_ip_address_count(count, 251)
        count+=1
      end
      subnets= subnets.get_json

      desc_subnets = ZAWS::External::AWSCLI::Commands::EC2::DescribeSubnets.new
      aws_command = ZAWS::External::AWSCLI::Commands::AWS.new
      desc_subnets.filter.vpc_id("my_vpc_id")
      desc_subnets.aws.output("json").region("us-west-1").subcommand(desc_subnets)

      expect(@shellout).to receive(:cli).with(desc_subnets.aws.get_command, nil).and_return(subnets)

      security_groups = ZAWS::External::AWSCLI::Generators::Result::EC2::SecurityGroups.new
      security_groups = security_groups.description(0, "My security group").group_name(0, "my_security_group_name")
      security_groups = security_groups.owner_id(0, "123456789012").group_id(0, "sg-903004f8")
      sgroups = security_groups.get_json

      desc_sec_grps = ZAWS::External::AWSCLI::Commands::EC2::DescribeSecurityGroups.new
      desc_sec_grps.filter.vpc_id("my_vpc_id").group_name("my_security_group_name")
      desc_sec_grps.aws.output("json").region("us-west-1")

      expect(@shellout).to receive(:cli).with(desc_sec_grps.aws.get_command, nil).and_return(sgroups)

      network_interfaces=ZAWS::External::AWSCLI::Commands::EC2::NetworkInterfaces.new
      network_interfaces=network_interfaces.add_group(0, "sg-903004f8").private_ip_address(0, "10.0.0.6")
      network_interfaces=network_interfaces.device_index(0, 0).subnet_id(0, "subnet-YYYYYY")

      bdm = @aws.ec2.compute.network_interface_json('us-west-1', nil, 'my_vpc_id', '10.0.0.6', 'my_security_group_name')
      expect(bdm).to eq(network_interfaces.get_network_interfaces_array_to_json)
    end

  end
end



