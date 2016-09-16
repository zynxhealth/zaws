require 'spec_helper'

describe ZAWS::Services::EC2::Compute do

  let (:vpc_id) { "my_vpc_id" }
  let (:external_id) { "my_instance" }
  let (:output_json) { "json" }
  let (:region) { "us-west-1" }
  let (:security_group_name) { "my_security_group" }
  let (:instance_id) { "i-12345678" }

  let (:describe_instances) {
    tags = ZAWS::External::AWSCLI::Generators::Result::EC2::Tags.new
    tags = tags.add("externalid", external_id)
    desc_instances = ZAWS::External::AWSCLI::Commands::EC2::DescribeInstances.new
    desc_instances.filter.vpc_id(vpc_id).tags(tags)
    desc_instances.aws.output(output_json).region(region)
    desc_instances
  }

  let (:instances) {
    tags = ZAWS::External::AWSCLI::Generators::Result::EC2::Tags.new
    tags = tags.add("externalid", external_id)
    instances = ZAWS::External::AWSCLI::Generators::Result::EC2::Instances.new
    net_interfaces= ZAWS::External::AWSCLI::Generators::Result::EC2::NetworkInterfaces.new
    pias=ZAWS::External::AWSCLI::Generators::Result::EC2::PrivateIpAddresses.new
    pias.private_ip_address(0, "0.0.0.0")
    net_interfaces.private_ip_addresses(0, pias)
    net_interfaces.network_interface_id(0, "net-123")
    instances.instance_id(0, instance_id).tags(0, tags)
    instances.network_interfaces(0, net_interfaces)
  }

  let (:empty_instances) {
    instances = ZAWS::External::AWSCLI::Generators::Result::EC2::Instances.new
  }

  let(:ok_instance_exists) { ZAWS::Helper::Output.colorize("OK: Instance already exists.", AWS_consts::COLOR_GREEN) }
  let(:critical_instance_exists) { ZAWS::Helper::Output.colorize("CRITICAL: Instance does not exist.", AWS_consts::COLOR_RED) }

  before(:each) {

    @var_security_group_id="sg-abcd1234"
    @var_output_json="json"
    @var_output_table="table"
    @var_region="us-west-1"
    @var_vpc_id="my_vpc_id"
    @var_sec_group_name="my_security_group_name"

    options_json = {:region => @var_region,
                    :verbose => false,
                    :check => false,
                    :undofile => false,
                    :viewtype => 'json'
    }

    options_json_vpcid = {:region => @var_region,
                          :verbose => false,
                          :check => true,
                          :undofile => false,
                          :viewtype => 'json',
                          :vpcid => @var_vpc_id,
                          :privateip => "10.0.0.6",
                          :optimized => true,
                          :apiterminate => true,
                          :clienttoken => 'test_token',
                          :skipruncheck => true
    }

    options_table = {:region => @var_region,
                     :verbose => false,
                     :check => false,
                     :undofile => false,
                     :viewtype => 'table'
    }


    @textout=double('outout')
    @shellout=double('ZAWS::Helper::Shell')
    @undofile=double('ZAWS::Helper::ZFile')
    @aws=ZAWS::AWS.new(@shellout, ZAWS::AWSCLI.new(@shellout, true), @undofile)
    @command_compute = ZAWS::Command::Compute.new([], options_table, {})
    @command_compute.aws=@aws
    @command_compute.out=@textout
    @command_compute.print_exit_code = true
    @command_compute_json = ZAWS::Command::Compute.new([], options_json, {})
    @command_compute_json.aws=@aws
    @command_compute_json.out=@textout
    @command_compute_json.print_exit_code = true
    @command_compute_json_vpcid = ZAWS::Command::Compute.new([], options_json_vpcid, {})
    @command_compute_json_vpcid.aws=@aws
    @command_compute_json_vpcid.out=@textout
    @command_compute_json_vpcid.print_exit_code = true

  }

  describe "#view" do
    it "Get compute instances in a human readable table." do
      desc_compute = ZAWS::External::AWSCLI::Commands::EC2::DescribeInstances.new
      desc_compute.aws.output(@var_output_table).region(@var_region)
      expect(@shellout).to receive(:cli).with(desc_compute.aws.get_command, nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @command_compute.view
    end

    it "Get compute instances in JSON form " do
      desc_compute = ZAWS::External::AWSCLI::Commands::EC2::DescribeInstances.new
      desc_compute.aws.output(@var_output_json).region(@var_region)
      expect(@shellout).to receive(:cli).with(desc_compute.aws.get_command, nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @command_compute_json.view
    end

    it "Get compute instances from specified vpcid" do
      desc_compute = ZAWS::External::AWSCLI::Commands::EC2::DescribeInstances.new
      desc_compute.filter.vpc_id(@var_vpc_id)
      desc_compute.aws.output(@var_output_json).region(@var_region)
      expect(@shellout).to receive(:cli).with(desc_compute.aws.get_command, nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @command_compute_json_vpcid.view
    end
  end

  describe "#exists" do
    context "instance exists" do
      it "returns true" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@textout).to receive(:puts).with("true")
        @command_compute_json_vpcid.exists_by_external_id(external_id)
      end
    end
    context "instance does not exist" do
      it "returns false" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(empty_instances.get_json)
        expect(@textout).to receive(:puts).with("false")
        @command_compute_json_vpcid.exists_by_external_id(external_id)
      end
    end
  end

  describe "#declare" do
    context "check flag provided and instance exists" do
      it "ok" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@textout).to receive(:puts).with(ok_instance_exists)
        @command_compute_json_vpcid.declare(external_id, 'ami-abc123', 'self', 'x1-large', 70, 'us-west-1a', 'sshkey', 'mysecuritygroup')
      end
    end
    context "check flag provided and instance does not exist" do
      it "critical" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(empty_instances.get_json)
        expect(@textout).to receive(:puts).with(critical_instance_exists)
        @command_compute_json_vpcid.declare(external_id, 'ami-abc123', 'self', 'x1-large', 70, 'us-west-1a', 'sshkey', 'mysecuritygroup')
      end
    end
  end

end


