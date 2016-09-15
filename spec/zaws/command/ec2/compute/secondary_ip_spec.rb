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
    tags = tags.add("externalid", "my_instance")
    desc_instances = ZAWS::External::AWSCLI::Commands::EC2::DescribeInstances.new
    desc_instances.filter.vpc_id(vpc_id).tags(tags)
    desc_instances.aws.output(output_json).region(region)
    desc_instances
  }

  let (:instances) {
    tags = ZAWS::External::AWSCLI::Generators::Result::EC2::Tags.new
    tags = tags.add("externalid", "my_instance")
    instances = ZAWS::External::AWSCLI::Generators::Result::EC2::Instances.new
    net_interfaces= ZAWS::External::AWSCLI::Generators::Result::EC2::NetworkInterfaces.new
    pias=ZAWS::External::AWSCLI::Generators::Result::EC2::PrivateIpAddresses.new
    pias.private_ip_address(0, "0.0.0.0")
    net_interfaces.private_ip_addresses(0, pias)
    net_interfaces.network_interface_id(0, "net-123")
    instances.instance_id(0, instance_id).tags(0, tags)
    instances.network_interfaces(0, net_interfaces)
  }

  let (:assign_private_ip_addresses) {
    apia = ZAWS::External::AWSCLI::Commands::EC2::AssignPrivateIpAddresses.new
    apia.network_interface_id('net-123').private_ip_addresses('0.0.0.1')
    apia.aws.output(output_json).region(region)
    apia
  }

  let (:unassign_private_ip_addresses) {
    upia = ZAWS::External::AWSCLI::Commands::EC2::UnassignPrivateIpAddresses.new
    upia.network_interface_id('net-123').private_ip_addresses('0.0.0.0')
    upia.aws.output(output_json).region(region)
    upia
  }

  let(:skip_assignment) { ZAWS::Helper::Output.colorize("Secondary ip already exists. Skipping assignment.", AWS_consts::COLOR_GREEN) }
  let(:secondary_ip_assigned) { ZAWS::Helper::Output.colorize("Secondary ip assigned.", AWS_consts::COLOR_YELLOW) }
  let(:secondary_ip_unassigned) { ZAWS::Helper::Output.colorize("Secondary ip deleted.", AWS_consts::COLOR_YELLOW) }
  let(:secondary_ip_skip_deletion) { ZAWS::Helper::Output.colorize("Secondary IP does not exists, skipping deletion.", AWS_consts::COLOR_GREEN) }
  let(:ok_secondary_ip) { ZAWS::Helper::Output.colorize("OK: Secondary ip exists.", AWS_consts::COLOR_GREEN) }
  let(:critical_secondary_ip) { ZAWS::Helper::Output.colorize("CRITICAL: Secondary ip does not exist.", AWS_consts::COLOR_RED) }

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

    @textout=double('outout')
    @shellout=double('ZAWS::Helper::Shell')
    @undofile=double('ZAWS::Helper::ZFile')
    @aws=ZAWS::AWS.new(@shellout, ZAWS::AWSCLI.new(@shellout, true), @undofile)

    @command_compute_json = ZAWS::Command::Compute.new([], options_json, {})
    @command_compute_json.aws=@aws
    @command_compute_json.out=@textout
    @command_compute_json.print_exit_code = true
    @command_compute_json_vpcid = ZAWS::Command::Compute.new([], options_json_vpcid, {})
    @command_compute_json_vpcid.aws=@aws
    @command_compute_json_vpcid.out=@textout
    @command_compute_json_vpcid.print_exit_code = true

    @command_compute_json_vpcid_check = ZAWS::Command::Compute.new([], options_json_vpcid_check, {})
    @command_compute_json_vpcid_check.aws=@aws
    @command_compute_json_vpcid_check.out=@textout
    @command_compute_json_vpcid_check.print_exit_code = true

        @command_compute_json_vpcid_undo = ZAWS::Command::Compute.new([], options_json_vpcid_undo, {})
    @command_compute_json_vpcid_undo.aws=@aws
    @command_compute_json_vpcid_undo.out=@textout
    @command_compute_json_vpcid_undo.print_exit_code = true

  }

  describe "#exists_secondary_ip" do

    context "secondary ip exists on instance" do
      it "Determine secondary ip exists on instance by external ip" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@textout).to receive(:puts).with("true")
        @command_compute_json_vpcid.exists_secondary_ip(external_id, "0.0.0.0")
      end
    end

    context "secondary ip does not exists on instance" do
      it "Determine secondary ip does not exists on instance by external ip" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@textout).to receive(:puts).with("false")
        @command_compute_json_vpcid.exists_secondary_ip(external_id, "0.0.0.1")
      end
    end

  end

  describe "#declare" do
    context "secondary ip does not exist on instance" do
      it "Declare secondary ip for instance by external ip" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(assign_private_ip_addresses.aws.get_command, nil).and_return('{ "return" : "true" }')
        expect(@textout).to receive(:puts).with(secondary_ip_assigned)
        @command_compute_json_vpcid.declare_secondary_ip(external_id, "0.0.0.1")
      end
      it "fail check when check flag present" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@textout).to receive(:puts).with(critical_secondary_ip)
        @command_compute_json_vpcid_check.declare_secondary_ip(external_id, "0.0.0.1")
      end
      it "creates an undo file when undo option file present" do
         expect(@undofile).to receive(:prepend).with("zaws compute delete_secondary_ip #{external_id} 0.0.0.1 --region #{region} --vpcid #{vpc_id} $XTRA_OPTS", '#Delete secondary ip', 'undo.sh')
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(assign_private_ip_addresses.aws.get_command, nil).and_return('{ "return" : "true" }')
        expect(@textout).to receive(:puts).with(secondary_ip_assigned)
        @command_compute_json_vpcid_undo.declare_secondary_ip(external_id, "0.0.0.1")
      end
    end
    context "secondary ip does exist on instance" do
      it "skips assignment" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@textout).to receive(:puts).with(skip_assignment)
        @command_compute_json_vpcid.declare_secondary_ip(external_id, "0.0.0.0")
      end
      it "pass check when check flag present" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@textout).to receive(:puts).with(ok_secondary_ip)
        @command_compute_json_vpcid_check.declare_secondary_ip(external_id, "0.0.0.0")
      end
    end

  end
  describe "#delete" do

    context "secondary ip does exist on instance" do
      it "unassign it" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(unassign_private_ip_addresses.aws.get_command, nil).and_return('{ "return" : "true" }')
        expect(@textout).to receive(:puts).with(secondary_ip_unassigned)
        @command_compute_json_vpcid.delete_secondary_ip(external_id, "0.0.0.0")
      end
    end
    context "secondary ip does not exist on instance" do
      it "skip unassignment" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@textout).to receive(:puts).with(secondary_ip_skip_deletion)
        @command_compute_json_vpcid.delete_secondary_ip(external_id, "0.0.0.1")
      end
    end
  end

end




