require 'spec_helper'

describe ZAWS::Services::EC2::Compute do

  let (:vpc_id) { "my_vpc_id" }
  let (:external_id) { "my_instance" }
  let (:output_json) { "json" }
  let (:region) { "us-west-1" }
  let (:security_group_name) { "my_security_group" }
  let (:instance_id) {"i-12345678"}
  let (:describe_instances) {
    tags = ZAWS::External::AWSCLI::Generators::Result::EC2::Tags.new
    tags = tags.add("externalid", "my_instance")
    desc_instances = ZAWS::External::AWSCLI::Commands::EC2::DescribeInstances.new
    desc_instances.filter.vpc_id(vpc_id).tags(tags)
    desc_instances.aws.output(output_json).region(region)
    desc_instances
  }

  let (:describe_security_groups_by_name_by_vpcid) {
    desc_sec_grps = ZAWS::External::AWSCLI::Commands::EC2::DescribeSecurityGroups.new
    desc_sec_grps.filter.group_name(security_group_name).vpc_id(vpc_id)
    desc_sec_grps.aws.output(output_json).region(region)
    desc_sec_grps }

  let (:security_groups) {
    security_groups = ZAWS::External::AWSCLI::Generators::Result::EC2::SecurityGroups.new
    security_groups.group_name(0, security_group_name).group_id(0, "sg-X")
  }

  let (:security_groups2) {
    security_groups = ZAWS::External::AWSCLI::Generators::Result::EC2::SecurityGroups.new
    security_groups.group_name(0, security_group_name).group_id(0, "sg-Y")
  }

  let (:instances) {
    tags = ZAWS::External::AWSCLI::Generators::Result::EC2::Tags.new
    tags = tags.add("externalid", "my_instance")
    instances = ZAWS::External::AWSCLI::Generators::Result::EC2::Instances.new
    instances.instance_id(0,instance_id ).security_groups(0, security_groups).tags(0, tags)
  }

  let(:security_group_same) { ZAWS::Helper::Output.colorize("Security Group Association Not Changed.", AWS_consts::COLOR_GREEN) }
  let(:security_group_changed) { ZAWS::Helper::Output.colorize("Security Group Association Changed.", AWS_consts::COLOR_YELLOW) }

  let (:modify_instance_attribute) {
    mia = ZAWS::External::AWSCLI::Commands::EC2::ModifyInstanceAttribute.new
    mia.instance_id(instance_id).security_groups("sg-Y")
    mia.aws.region(region)
    mia }

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

  }

  describe "#exists_security_group_assoc" do

    context "instance associated to security group" do
      it "Determine a scurity group is associated to instance by external id" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_security_groups_by_name_by_vpcid.aws.get_command, nil).and_return(security_groups.get_json)
        expect(@textout).to receive(:puts).with("true")
        @command_compute_json_vpcid.exists_security_group_assoc(external_id, security_group_name)
      end
    end
    context "instance not associated to security group" do
      it "Determine a scurity group is not associated to instance by external id" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_security_groups_by_name_by_vpcid.aws.get_command, nil).and_return(security_groups2.get_json)
        expect(@textout).to receive(:puts).with("false")
        @command_compute_json_vpcid.exists_security_group_assoc(external_id, security_group_name)
      end
    end
  end

  describe "#assoc_security_group" do
    context "security group not associated to instance" do
      it "Change security group of instance by external id" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_security_groups_by_name_by_vpcid.aws.get_command, nil).and_return(security_groups2.get_json)
        expect(@shellout).to receive(:cli).with(modify_instance_attribute.aws.get_command, nil).and_return('{  "return": "true" }')
        expect(@textout).to receive(:puts).with(security_group_changed)
        @command_compute_json_vpcid.assoc_security_group(external_id, security_group_name)
      end
    end

    context "security group associated to instance" do
      it "Not Change security group of instance by external id" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_security_groups_by_name_by_vpcid.aws.get_command, nil).and_return(security_groups.get_json)
        expect(@textout).to receive(:puts).with(security_group_same)
        @command_compute_json_vpcid.assoc_security_group(external_id, security_group_name)
      end
    end
  end
end


