require 'spec_helper'

describe ZAWS::Services::EC2::Compute do

  let(:instance_exists_skip_creation) { ZAWS::Helper::Output.colorize("Instance already exists. Creation skipped.", AWS_consts::COLOR_GREEN) }
  let(:instance_created) { ZAWS::Helper::Output.colorize("Instance created.", AWS_consts::COLOR_YELLOW) }
  let(:instance_deleted) { ZAWS::Helper::Output.colorize("Instance deleted.", AWS_consts::COLOR_YELLOW) }
  let(:instance_not_deleted) { ZAWS::Helper::Output.colorize("Instance does not exist. Skipping deletion.", AWS_consts::COLOR_GREEN) }

  let (:vpc_id) { "my_vpc_id" }
  let (:cidr_subnet) { "10.0.0.0/24" }
  let (:external_id) { "my_instance" }
  let (:output_json) { "json" }
  let (:region) { "us-west-1" }
  let (:security_group_name) { "my_security_group" }
  let (:instance_id) { "i-12345678" }
  let (:security_group_id) { "sg-abcd1234" }
  let (:image_id) { "ami-abc123" }

  let (:describe_instances) {
    tags = ZAWS::External::AWSCLI::Generators::Result::EC2::Tags.new
    tags = tags.add("externalid", external_id)
    desc_instances = ZAWS::External::AWSCLI::Commands::EC2::DescribeInstances.new
    desc_instances.filter.vpc_id(vpc_id).tags(tags)
    desc_instances.aws.output(output_json).region(region)
    desc_instances
  }

  let (:terminate_instances) {
    ti = ZAWS::External::AWSCLI::Commands::EC2::TerminateInstances.new
    ti.aws.region(region)
    ti.instance_id(instance_id)
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

  let(:images) {
    i = ZAWS::External::AWSCLI::Generators::Result::EC2::Images.new
    i.root_device_name(0, "/dev/sda")
    i.block_device_mappings(0, [{"DeviceName" => "/dev/sda1", "Ebs" => {
        "DeleteOnTermination" => true,
        "SnapshotId" => "snap-XXX",
        "VolumeSize" => 7,
        "VolumeType" => "standard"}}])
  }

  let (:describe_images) {
    desc_image = ZAWS::External::AWSCLI::Commands::EC2::DescribeImages.new
    desc_image.aws.output(output_json).region(region)
    desc_image.owner("self").image_ids(image_id)
  }

  let(:describe_subnets) {
    desc_subnets = ZAWS::External::AWSCLI::Commands::EC2::DescribeSubnets.new
    desc_subnets.filter.vpc_id(vpc_id)
    desc_subnets.aws.output("json").region(region)
    desc_subnets
  }

  let(:subnets) {

    subnets = ZAWS::External::AWSCLI::Generators::Result::EC2::Subnets.new
    subnets.vpc_id(0, vpc_id).cidr_block(0, cidr_subnet).map_public_ip_on_launch(0, false)
    subnets.default_for_az(0, false).state(0, "available").subnet_id(0, "subnet-XXXXXX")
    subnets.available_ip_address_count(0, 251)

  }

  let(:describe_security_groups) {
    desc_sec_grps = ZAWS::External::AWSCLI::Commands::EC2::DescribeSecurityGroups.new
    desc_sec_grps.filter.group_name(security_group_name).vpc_id(vpc_id)
    desc_sec_grps.aws.output(output_json).region(region)
    desc_sec_grps }

  let(:single_security_group) {
    security_groups = ZAWS::External::AWSCLI::Generators::Result::EC2::SecurityGroups.new
    security_groups.group_name(0, security_group_name).group_id(0, security_group_id)
  }

  let(:create_tags1) {
    tags = ZAWS::External::AWSCLI::Generators::Result::EC2::Tags.new
    tags = tags.add("externalid", external_id)
    create_tags = ZAWS::External::AWSCLI::Commands::EC2::CreateTags.new
    create_tags.resource(instance_id).tags(tags)
    create_tags.aws.region(region).output(output_json)
    create_tags
  }

  let(:create_tags2) {
    tags = ZAWS::External::AWSCLI::Generators::Result::EC2::Tags.new
    tags = tags.add("Name", external_id)
    create_tags = ZAWS::External::AWSCLI::Commands::EC2::CreateTags.new
    create_tags.resource(instance_id).tags(tags)
    create_tags.aws.region(region).output(output_json)
    create_tags
  }

  let(:modify_instance_attr) {
    mia = ZAWS::External::AWSCLI::Commands::EC2::ModifyInstanceAttribute.new
    mia.aws.output(output_json).region(region)
    mia.instance_id(instance_id).no_source_dest_check
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
                          :check => false,
                          :undofile => false,
                          :viewtype => 'json',
                          :vpcid => @var_vpc_id,
                          :privateip => ["10.0.0.6"],
                          :optimized => true,
                          :apiterminate => true,
                          :clienttoken => 'test_token',
                          :skipruncheck => true,
                          :tenancy => 'dedicated',
                          :profilename => 'myrole',
                          :nosdcheck => true
    }
    options_json_vpcid_check = {:region => @var_region,
                                :verbose => false,
                                :check => true,
                                :undofile => false,
                                :viewtype => 'json',
                                :vpcid => @var_vpc_id,
                                :privateip => ["10.0.0.6"],
                                :optimized => true,
                                :apiterminate => true,
                                :clienttoken => 'test_token',
                                :skipruncheck => true
    }
    options_json_vpcid_undo = {:region => @var_region,
                               :verbose => false,
                               :check => false,
                               :undofile => "undo.sh",
                               :viewtype => 'json',
                               :vpcid => @var_vpc_id,
                               :privateip => ["10.0.0.6"],
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
    @command_compute_json_vpcid_check = ZAWS::Command::Compute.new([], options_json_vpcid_check, {})
    @command_compute_json_vpcid_check.aws=@aws
    @command_compute_json_vpcid_check.out=@textout
    @command_compute_json_vpcid_check.print_exit_code = true
    @command_compute_json_vpcid_undo = ZAWS::Command::Compute.new([], options_json_vpcid_undo, {})
    @command_compute_json_vpcid_undo.aws=@aws
    @command_compute_json_vpcid_undo.out=@textout
    @command_compute_json_vpcid_undo.print_exit_code = true
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
        @command_compute_json_vpcid_check.declare(external_id, 'ami-abc123', 'self', 'x1-large', 70, 'us-west-1a', 'sshkey', 'mysecuritygroup')
      end
    end
    context "check flag provided and instance does not exist" do
      it "critical" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(empty_instances.get_json)
        expect(@textout).to receive(:puts).with(critical_instance_exists)
        @command_compute_json_vpcid_check.declare(external_id, 'ami-abc123', 'self', 'x1-large', 70, 'us-west-1a', 'sshkey', 'mysecuritygroup')
      end
    end
    context "instance exists" do
      it "skip creation" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@textout).to receive(:puts).with(instance_exists_skip_creation)
        @command_compute_json_vpcid.declare(external_id, 'ami-abc123', 'self', 'x1-large', 70, 'us-west-1a', 'sshkey', 'mysecuritygroup')
      end
    end
    context "undo file specified and instance exists" do
      it "write out undo file, skip creation" do
        expect(@undofile).to receive(:prepend).with("zaws compute delete #{external_id} --region #{region} --vpcid #{vpc_id} $XTRA_OPTS", '#Delete instance', 'undo.sh')
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@textout).to receive(:puts).with(instance_exists_skip_creation)
        @command_compute_json_vpcid_undo.declare(external_id, 'ami-abc123', 'self', 'x1-large', 70, 'us-west-1a', 'sshkey', 'mysecuritygroup')
      end
    end
    context "instance does not exists" do
      it "create instance" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(empty_instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_images.aws.get_command, nil).and_return(images.get_json)
        expect(@shellout).to receive(:cli).with(describe_subnets.aws.get_command, nil).and_return(subnets.get_json)
        expect(@shellout).to receive(:cli).with(describe_security_groups.aws.get_command, nil).and_return(single_security_group.get_json)
        expect(@shellout).to receive(:cli).with("aws --region us-west-1 ec2 run-instances --image-id ami-abc123 --key-name sshkey --instance-type x1-large --placement AvailabilityZone=us-west-1a,Tenancy=dedicated --block-device-mappings \"[{\\\"DeviceName\\\":\\\"/dev/sda1\\\",\\\"Ebs\\\":{\\\"DeleteOnTermination\\\":true,\\\"SnapshotId\\\":\\\"snap-XXX\\\",\\\"VolumeSize\\\":7,\\\"VolumeType\\\":\\\"standard\\\"}}]\" --enable-api-termination --client-token test_token --network-interfaces \"[{\\\"Groups\\\":[\\\"sg-abcd1234\\\"],\\\"PrivateIpAddress\\\":\\\"10.0.0.6\\\",\\\"DeviceIndex\\\":0,\\\"SubnetId\\\":\\\"subnet-XXXXXX\\\"}]\" --iam-instance-profile Name=\"myrole\" --ebs-optimized", nil).and_return("{ \"Instances\" : [ {\"InstanceId\": \"#{instance_id}\",\"Tags\": [ ] } ] }")
        expect(@shellout).to receive(:cli).with(create_tags1.aws.get_command, nil).and_return('{ "return":"true" }')
        expect(@shellout).to receive(:cli).with(create_tags2.aws.get_command, nil).and_return('{ "return":"true" }')
        expect(@shellout).to receive(:cli).with(modify_instance_attr.aws.get_command, nil).and_return('{ "return":"true" }')
        expect(@textout).to receive(:puts).with(instance_created)
        @command_compute_json_vpcid.declare(external_id, 'ami-abc123', 'self', 'x1-large', 70, 'us-west-1a', 'sshkey', 'my_security_group')
      end
    end
  end

  describe "#delete" do
    context "instance exists" do
      it "terminates instance" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(terminate_instances.aws.get_command, nil).and_return('{  "TerimatingInstances": [ ] }')
        expect(@textout).to receive(:puts).with(instance_deleted)
        @command_compute_json_vpcid.delete(external_id)
      end
    end
    context "instance does not exists" do
      it "skip termination" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(empty_instances.get_json)
        expect(@textout).to receive(:puts).with(instance_not_deleted)
        @command_compute_json_vpcid.delete(external_id)
      end
    end
  end

end


