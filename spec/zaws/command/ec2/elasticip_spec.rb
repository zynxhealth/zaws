require 'spec_helper'

describe ZAWS::Services::EC2::Elasticip do

  let(:new_elastic_ip_associated) { ZAWS::Helper::Output.colorize("New elastic ip associated to instance.", AWS_consts::COLOR_YELLOW) }
  let(:elastic_ip_association_exists) { ZAWS::Helper::Output.colorize("instance already has an elastic ip. Skipping creation.", AWS_consts::COLOR_GREEN) }
  let(:elasticip_deleted) { ZAWS::Helper::Output.colorize("Deleted elasticip.", AWS_consts::COLOR_YELLOW) }
  let(:skip_elastic_deletion) { ZAWS::Helper::Output.colorize("Elasticip does not exist. Skipping deletion.", AWS_consts::COLOR_GREEN) }
  let(:ok_elastic_ip) { ZAWS::Helper::Output.colorize("OK: Elastic Ip exists.", AWS_consts::COLOR_GREEN) }
  let(:critical_elastic_ip) { ZAWS::Helper::Output.colorize("CRITICAL: Elastic Ip DOES NOT EXIST.", AWS_consts::COLOR_RED) }

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

  let (:allocate_address) {
    addr = ZAWS::External::AWSCLI::Commands::EC2::AllocateAddress.new
    addr.aws.region(region)
    addr.domain("vpc")
  }

  let (:address_allocation) {
    addr = ZAWS::External::AWSCLI::Generators::Result::EC2::AllocationId.new
    addr.public_ip("198.51.100.0").domain("vpc").allocation_id("eipalloc-abcd1234")
  }

  let (:associate_address) {
    addr = ZAWS::External::AWSCLI::Commands::EC2::AssociateAddress.new
    addr.aws.region(region)
    addr.instance_id("my_instance").allocation_id("eipalloc-abcd1234")
  }

  let (:address_association) {
    addr = ZAWS::External::AWSCLI::Generators::Result::EC2::AssociationId.new
    addr.association_id("eipalloc-abcd1234")
  }
  let (:disassociate_address) {
    addr = ZAWS::External::AWSCLI::Commands::EC2::DisassociateAddress.new
    addr.aws.region(region)
    addr.association_id("eipassoc-abcd1234")
  }

  let (:release_address) {
    addr = ZAWS::External::AWSCLI::Commands::EC2::ReleaseAddress.new
    addr.aws.region(region)
    addr.allocation_id("eipalloc-abcd1234")
  }

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

    options_json_vpcid_check = {:region => @var_region,
                                :verbose => false,
                                :check => true,
                                :undofile => false,
                                :viewtype => 'json',
                                :vpcid => @var_vpc_id
    }

    options_json_vpcid_undo = {:region => @var_region,
                               :verbose => false,
                               :check => false,
                               :undofile => 'undo.sh',
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

    @command_addresses_json_vpcid_check = ZAWS::Command::Elasticip.new([], options_json_vpcid_check, {})
    @command_addresses_json_vpcid_check.aws=@aws
    @command_addresses_json_vpcid_check.out=@textout
    @command_addresses_json_vpcid_check.print_exit_code = true

    @command_addresses_json_vpcid_undo = ZAWS::Command::Elasticip.new([], options_json_vpcid_undo, {})
    @command_addresses_json_vpcid_undo.aws=@aws
    @command_addresses_json_vpcid_undo.out=@textout
    @command_addresses_json_vpcid_undo.print_exit_code = true

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

  describe "#declare" do
    context "instance exists without a elastic ip" do
      it "creates an address and associates it to the instance" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_addresses.aws.get_command, nil).and_return(empty_addresses.get_json)
        expect(@shellout).to receive(:cli).with(allocate_address.aws.get_command, nil).and_return(address_allocation.get_json)
        expect(@shellout).to receive(:cli).with(associate_address.aws.get_command, nil).and_return(address_association.get_json)
        expect(@textout).to receive(:puts).with(new_elastic_ip_associated)
        @command_addresses_json_vpcid.declare("my_instance")
      end
    end
    context "instance exists with elastic ip" do
      it "skip allocation and creation" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_addresses.aws.get_command, nil).and_return(addresses.get_json)
        expect(@textout).to receive(:puts).with(elastic_ip_association_exists)
        @command_addresses_json_vpcid.declare("my_instance")
      end
    end
    context "check flag used and instance exists without a elastic ip" do
      it "responds with critical" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_addresses.aws.get_command, nil).and_return(empty_addresses.get_json)
        expect(@textout).to receive(:puts).with(critical_elastic_ip)
        @command_addresses_json_vpcid_check.declare("my_instance")
      end
    end
    context "check flag used and instance exists with a elastic ip" do
      it "responds with ok" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_addresses.aws.get_command, nil).and_return(addresses.get_json)
        expect(@textout).to receive(:puts).with(ok_elastic_ip)
        @command_addresses_json_vpcid_check.declare("my_instance")
      end
    end
    context "undo flag used and instance exists without a elastic ip" do
      it "writes undo file with reverse procedure and creates elastic ip/associates it" do
        expect(@undofile).to receive(:prepend).with("zaws elasticip release #{instance_id} --region #{region} --vpcid #{vpc_id} $XTRA_OPTS", '#Release elastic ip.', 'undo.sh')
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_addresses.aws.get_command, nil).and_return(empty_addresses.get_json)
        expect(@shellout).to receive(:cli).with(allocate_address.aws.get_command, nil).and_return(address_allocation.get_json)
        expect(@shellout).to receive(:cli).with(associate_address.aws.get_command, nil).and_return(address_association.get_json)
        expect(@textout).to receive(:puts).with(new_elastic_ip_associated)
        @command_addresses_json_vpcid_undo.declare("my_instance")
      end
    end
  end

  describe "#delete" do
    context "instance exists with elastic ip" do
      it "disassociates elastic ip and releases it" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_addresses.aws.get_command, nil).and_return(addresses.get_json)
        expect(@shellout).to receive(:cli).with(disassociate_address.aws.get_command, nil).and_return('{  "return": "true" }')
        expect(@shellout).to receive(:cli).with(release_address.aws.get_command, nil).and_return('{  "return": "true" }')
        expect(@textout).to receive(:puts).with(elasticip_deleted)
        @command_addresses_json_vpcid.release("my_instance")
      end
    end
    context "elastic ip is not associated to instance" do
      it "skips deletion" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_addresses.aws.get_command, nil).and_return(empty_addresses.get_json)
        expect(@textout).to receive(:puts).with(skip_elastic_deletion)
        @command_addresses_json_vpcid.release("my_instance")
      end
    end
  end
end

