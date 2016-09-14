require 'spec_helper'

describe ZAWS::Services::EC2::Elasticip do

  let(:output_json) { "json" }
  let(:region) { "us-west-1" }
  let(:vpc_id) { "my_vpc_id" }
  let(:instance_id) { "my_instance" }

  let (:tags) {
    tags = ZAWS::External::AWSCLI::Generators::Result::EC2::Tags.new
    tags.add("externalid", instance_id)
  }

  let (:describe_instances) {
    desc_compute = ZAWS::External::AWSCLI::Commands::EC2::DescribeInstances.new
    desc_compute.filter.vpc_id(vpc_id).tags(tags)
    desc_compute.aws.output(output_json).region(region)
    desc_compute
  }

  let (:instances) {
    instances = ZAWS::External::AWSCLI::Generators::Result::EC2::Instances.new
    instances.instance_id(0, instance_id).tags(0, tags)
  }

  let (:describe_addresses) {
    da= ZAWS::External::AWSCLI::Commands::EC2::DescribeAddresses.new
    da.filter.domain("vpc").instance_id(instance_id)
    da.aws.output(output_json).region(region)
    da
  }

  let (:addresses) {
    addr = ZAWS::External::AWSCLI::Generators::Result::EC2::Addresses.new
    addr.instance_id(0, "i-abc1234").public_ip(0, "198.51 .100 .0").domain(0, "vpc")
    addr.association_id(0, "eipassoc-abcd1234").allocation_id(0, "eipalloc-abcd1234")
  }

  let (:empty_addresses) {
    addr = ZAWS::External::AWSCLI::Generators::Result::EC2::Addresses.new
    addr
  }
  #
  # let (:allocate_address) {
  #   addr = ZAWS::External::AWSCLI::Generators::Result::EC2::AllocateAddress.new
  #   addr.domain("vpc")
  # }
  #
  # let (:address_allocation) {
  #   addr = ZAWS::External::AWSCLI::Generators::Result::EC2::AllocationId.new
  #   addr.public_ip("198.51.100.0").domain("vpc").allocation_id("eipalloc-abcd1234")
  # }
  #
  # let (:associate_address) {
  #   addr = ZAWS::External::AWSCLI::Generators::Result::EC2::AssociateAddress.new
  #   addr.instance_id("i-abc1234").allocation_id("eipalloc-abcd1234")
  # }
  #
  # let (:address)

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
                          :check => false,
                          :undofile => false,
                          :viewtype => 'json',
                          :vpcid => @var_vpc_id
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
    @command_addresses = ZAWS::Command::Elasticip.new([], options_table, {})
    @command_addresses.aws=@aws
    @command_addresses.out=@textout
    @command_addresses.print_exit_code = true
    @command_addresses_json = ZAWS::Command::Elasticip.new([], options_json, {})
    @command_addresses_json.aws=@aws
    @command_addresses_json.out=@textout
    @command_addresses_json.print_exit_code = true

    @command_addresses_json_vpcid = ZAWS::Command::Elasticip.new([], options_json_vpcid, {})
    @command_addresses_json_vpcid.aws=@aws
    @command_addresses_json_vpcid.out=@textout
    @command_addresses_json_vpcid.print_exit_code = true

  }

  describe "#view" do

    it "Get elasticip in a human readable table." do
      desc_addresses = ZAWS::External::AWSCLI::Commands::EC2::DescribeAddresses.new
      desc_addresses.aws.output(@var_output_table).region(@var_region).subcommand(desc_addresses)
      expect(@shellout).to receive(:cli).with(desc_addresses.aws.get_command, nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @command_addresses.view
    end

    it "Get elasticip in JSON form " do
      desc_addresses = ZAWS::External::AWSCLI::Commands::EC2::DescribeAddresses.new
      desc_addresses.aws.output(@var_output_json).region(@var_region).subcommand(desc_addresses)
      expect(@shellout).to receive(:cli).with(desc_addresses.aws.get_command, nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @command_addresses_json.view
    end

  end

  describe "#assoc_exists" do
    context "elastic ip exists" do
      it "determines it exists" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_addresses.aws.get_command, nil).and_return(addresses.get_json)
        expect(@textout).to receive(:puts).with('true')
        @command_addresses_json_vpcid.assoc_exists("my_instance")
      end
    end
    context "elastic ip does not exists" do
      it "determines it does not exists" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_addresses.aws.get_command, nil).and_return(empty_addresses.get_json)
        expect(@textout).to receive(:puts).with('false')
        @command_addresses_json_vpcid.assoc_exists("my_instance")
      end
    end
  end
end


