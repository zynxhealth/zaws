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
    instances.instance_id(0, instance_id).tags(0, tags)
    instances.network_interfaces(0, net_interfaces)
  }


  let(:security_group_same) { ZAWS::Helper::Output.colorize("Security Group Association Not Changed.", AWS_consts::COLOR_GREEN) }
  let(:security_group_changed) { ZAWS::Helper::Output.colorize("Security Group Association Changed.", AWS_consts::COLOR_YELLOW) }


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


end




