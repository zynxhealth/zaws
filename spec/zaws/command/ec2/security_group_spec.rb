require 'spec_helper'

describe ZAWS::Services::EC2::SecurityGroup do

  let(:security_group_skip_deletion) { ZAWS::Helper::Output.colorize("Security Group does not exist. Skipping deletion.", AWS_consts::COLOR_GREEN) }
  let(:security_group_deleted) { ZAWS::Helper::Output.colorize("Security Group deleted.", AWS_consts::COLOR_YELLOW) }
  let(:security_group_exists) { ZAWS::Helper::Output.colorize("Security Group Exists Already. Skipping Creation.", AWS_consts::COLOR_GREEN) }
  let(:security_group_created) { ZAWS::Helper::Output.colorize("Security Group Created.", AWS_consts::COLOR_YELLOW) }
  let(:check_critical_security_group) { ZAWS::Helper::Output.colorize("CRITICAL: Security Group Does Not Exist.", AWS_consts::COLOR_RED) }
  let(:check_ok_security_group) { ZAWS::Helper::Output.colorize("OK: Security Group Exists.", AWS_consts::COLOR_GREEN) }

  let(:var_region) { "us-west-1" }
  let(:security_group_name) { "my_security_group_name" }
  let(:var_security_group_id) { "sg-abcd1234" }
  let(:var_output_json) { "json" }
  let(:var_output_table) { "table" }
  let(:var_vpc_id) { "my_vpc_id" }
  let(:var_sec_group_name) { "my_security_group_name" }

  let(:empty_security_group) { ZAWS::External::AWSCLI::Generators::Result::EC2::SecurityGroups.new }

  let(:single_security_group) {
    security_groups = ZAWS::External::AWSCLI::Generators::Result::EC2::SecurityGroups.new
    security_groups.group_name(0, security_group_name).group_id(0, var_security_group_id) }

  let(:describe_security_groups_by_name_by_vpcid) {
    desc_sec_grps = ZAWS::External::AWSCLI::Commands::EC2::DescribeSecurityGroups.new
    desc_sec_grps.filter.group_name(var_sec_group_name).vpc_id(var_vpc_id)
    desc_sec_grps.aws.output(var_output_json).region(var_region)
    desc_sec_grps }

  let(:describe_security_groups_by_name) {
    desc_sec_grps = ZAWS::External::AWSCLI::Commands::EC2::DescribeSecurityGroups.new
    desc_sec_grps.filter.group_name(var_sec_group_name)
    desc_sec_grps.aws.output(var_output_json).region(var_region)
    desc_sec_grps }


  before(:each) {

    @var_security_group_id="sg-abcd1234"
    @var_output_json="json"
    @var_output_table="table"
    @var_vpc_id="my_vpc_id"
    @var_sec_group_name="my_security_group_name"

    options = {:region => var_region,
               :verbose => false,
               :check => false,
               :undofile => false,
               :viewtype => 'table',
    }


    options_json = {:region => var_region,
                    :verbose => false,
                    :check => false,
                    :undofile => false,
                    :viewtype => 'json'
    }

    options_json_vpcid = {:region => var_region,
                          :verbose => false,
                          :check => false,
                          :undofile => false,
                          :viewtype => 'json',
                          :vpcid => @var_vpc_id
    }

    options_json_unused = {:region => var_region,
                           :verbose => false,
                           :check => false,
                           :undofile => false,
                           :viewtype => 'json',
                           :unused => true
    }

    options_json_vpcid_check = {:region => var_region,
                                :verbose => false,
                                :check => true,
                                :undofile => false,
                                :viewtype => 'json',
                                :vpcid => @var_vpc_id}

    options_json_vpcid_undo = {:region => var_region,
                               :verbose => false,
                               :check => false,
                               :undofile => 'undo.sh',
                               :viewtype => 'json',
                               :vpcid => @var_vpc_id}

    @textout=double('outout')
    @shellout=double('ZAWS::Helper::Shell')
    @undofile=double('ZAWS::Helper::ZFile')
    @aws=ZAWS::AWS.new(@shellout, ZAWS::AWSCLI.new(@shellout, true), @undofile)
    @command_security_group = ZAWS::Command::Security_Group.new([], options, {})
    @command_security_group.aws=@aws
    @command_security_group.out=@textout
    @command_security_group.print_exit_code = true

    @command_security_group_json = ZAWS::Command::Security_Group.new([], options_json, {})
    @command_security_group_json.aws=@aws
    @command_security_group_json.out=@textout
    @command_security_group_json.print_exit_code = true

    @command_security_group_json_unused = ZAWS::Command::Security_Group.new([], options_json_unused, {})
    @command_security_group_json_unused.aws=@aws
    @command_security_group_json_unused.out=@textout
    @command_security_group_json_unused.print_exit_code = true

    @command_security_group_json_vpcid = ZAWS::Command::Security_Group.new([], options_json_vpcid, {})
    @command_security_group_json_vpcid.aws=@aws
    @command_security_group_json_vpcid.out=@textout
    @command_security_group_json_vpcid.print_exit_code = true

    @command_security_group_json_vpcid_check = ZAWS::Command::Security_Group.new([], options_json_vpcid_check, {})
    @command_security_group_json_vpcid_check.aws=@aws
    @command_security_group_json_vpcid_check.out=@textout
    @command_security_group_json_vpcid_check.print_exit_code = true

    @command_security_group_json_vpcid_undo = ZAWS::Command::Security_Group.new([], options_json_vpcid_undo, {})
    @command_security_group_json_vpcid_undo.aws=@aws
    @command_security_group_json_vpcid_undo.out=@textout
    @command_security_group_json_vpcid_undo.print_exit_code = true

  }

  describe "#view" do
    it "Get security groups in a human readable table." do
      desc_sec_grps = ZAWS::External::AWSCLI::Commands::EC2::DescribeSecurityGroups.new
      desc_sec_grps.aws.output(@var_output_table).region(var_region)

      expect(@shellout).to receive(:cli).with(desc_sec_grps.aws.get_command, nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @command_security_group.view()
    end

    it "Get security groups in JSON form" do
      desc_sec_grps = ZAWS::External::AWSCLI::Commands::EC2::DescribeSecurityGroups.new
      desc_sec_grps.aws.output(@var_output_json).region(var_region)
      expect(@shellout).to receive(:cli).with(desc_sec_grps.aws.get_command, nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @command_security_group_json.view
    end

    it "Get security groups from specified vpcid" do
      desc_sec_grps = ZAWS::External::AWSCLI::Commands::EC2::DescribeSecurityGroups.new
      desc_sec_grps.filter.vpc_id(@var_vpc_id)
      desc_sec_grps.aws.output(@var_output_json).region(var_region)
      expect(@shellout).to receive(:cli).with(desc_sec_grps.aws.get_command, nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @command_security_group_json_vpcid.view
    end

    it "Get all security groups that are not actively associated to an instance" do
      security_groups = ZAWS::External::AWSCLI::Generators::Result::EC2::SecurityGroups.new
      security_groups = security_groups.group_name(0, "my_group_name").group_id(0, "sg-C2345678")

      instances = ZAWS::External::AWSCLI::Generators::Result::EC2::Instances.new
      net_interfaces= ZAWS::External::AWSCLI::Generators::Result::EC2::NetworkInterfaces.new
      net_interfaces=net_interfaces.network_interface_id(0, "eni-12345678").groups(0, security_groups)
      instances = instances.instance_id(0, "i-12345678")
      instances = instances.security_groups(0, security_groups)
      instances = instances.network_interfaces(0, net_interfaces)

      desc_instances = ZAWS::External::AWSCLI::Commands::EC2::DescribeInstances.new
      desc_instances.aws.output("json").region("us-west-1").subcommand(desc_instances)

      expect(@shellout).to receive(:cli).with(desc_instances.aws.get_command, nil).and_return(instances.get_json)

      security_groups = ZAWS::External::AWSCLI::Generators::Result::EC2::SecurityGroups.new
      security_groups = security_groups.group_name(0, "my_group_name").vpc_id(0, "vpc-12345678").owner_id(0, "123456789012").group_id(0, "sg-C2345678")
      security_groups = security_groups.group_name(1, "default").vpc_id(1, "vpc-1f6bb57a").owner_id(1, "123456789012").group_id(1, "sg-B2345678")
      security_groups = security_groups.group_name(2, "my_unused_group").vpc_id(2, "vpc-12345678").owner_id(2, "123456789012").group_id(2, "sg-A2345678")

      desc_sec_grps = ZAWS::External::AWSCLI::Commands::EC2::DescribeSecurityGroups.new
      desc_sec_grps.aws.output(@var_output_json).region(var_region)

      expect(@shellout).to receive(:cli).with(desc_sec_grps.aws.get_command, nil).ordered.and_return(security_groups.get_json)

      expect(@textout).to receive(:puts).with("default\nmy_unused_group").ordered
      @command_security_group_json_unused.view
    end
  end

  describe "#exists" do
    it "Determine a security group identified by name and vpc has NOT been created" do
      expect(@shellout).to receive(:cli).with(describe_security_groups_by_name_by_vpcid.aws.get_command, nil).ordered.and_return(empty_security_group.get_json)
      expect(@textout).to receive(:puts).with("false")
      @command_security_group_json_vpcid.exists_by_name(@var_sec_group_name)

    end

    it "Determine a security group identified by name and vpc has been created" do
      expect(@shellout).to receive(:cli).with(describe_security_groups_by_name_by_vpcid.aws.get_command, nil).ordered.and_return(single_security_group.get_json)
      expect(@textout).to receive(:puts).with("true")
      @command_security_group_json_vpcid.exists_by_name(@var_sec_group_name)

    end

    it "Determine a security group identified by name has NOT been created" do
      expect(@shellout).to receive(:cli).with(describe_security_groups_by_name.aws.get_command, nil).ordered.and_return(empty_security_group.get_json)
      expect(@textout).to receive(:puts).with("false")
      @command_security_group_json.exists_by_name(@var_sec_group_name)
    end

    it "Determine a security group identified by name has been created" do
      expect(@shellout).to receive(:cli).with(describe_security_groups_by_name.aws.get_command, nil).ordered.and_return(single_security_group.get_json)
      expect(@textout).to receive(:puts).with("true")
      @command_security_group_json.exists_by_name(@var_sec_group_name)

    end

  end

  describe "#delete" do

    it "Delete a security group in a vpc, but skip it cause it does not exist" do
      expect(@shellout).to receive(:cli).with(describe_security_groups_by_name_by_vpcid.aws.get_command, nil).ordered.and_return(empty_security_group.get_json)
      expect(@textout).to receive(:puts).with(security_group_skip_deletion)
      @command_security_group_json_vpcid.delete(@var_sec_group_name)
    end

    it "Delete a security group in a vpc" do
      security_groups = ZAWS::External::AWSCLI::Generators::Result::EC2::SecurityGroups.new
      security_groups = security_groups.group_name(0, @var_sec_group_name).group_id(0, "sg-YYYYYY")

      desc_sec_grps = ZAWS::External::AWSCLI::Commands::EC2::DescribeSecurityGroups.new
      desc_sec_grps.filter.group_name(@var_sec_group_name)
      desc_sec_grps.aws.output(@var_output_json).region(var_region)

      delete_security_group = ZAWS::External::AWSCLI::Commands::EC2::DeleteSecurityGroup.new
      delete_security_group.security_group_id("sg-YYYYYY")
      delete_security_group.aws.region(var_region)

      expect(@shellout).to receive(:cli).with(desc_sec_grps.aws.get_command, nil).ordered.and_return(security_groups.get_json)
      expect(@shellout).to receive(:cli).with(delete_security_group.aws.get_command, nil).and_return('{ "return": "true" }')
      expect(@textout).to receive(:puts).with(security_group_deleted)
      @command_security_group_json.delete(@var_sec_group_name)
    end
  end

  describe "#declare" do
    context "security group exists" do
      it "Declare a new security group in vpc, but don't create it" do
        expect(@shellout).to receive(:cli).with(describe_security_groups_by_name_by_vpcid.aws.get_command, nil).ordered.and_return(single_security_group.get_json)
        expect(@textout).to receive(:puts).with(security_group_exists)
        begin
          @command_security_group_json_vpcid.declare(@var_sec_group_name, "Description")
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end

    context "security group does not exist" do
      it "Declare a new security group in vpc, create it" do
        expect(@shellout).to receive(:cli).with(describe_security_groups_by_name_by_vpcid.aws.get_command, nil).ordered.and_return(empty_security_group.get_json)

        create_sec_grps = ZAWS::External::AWSCLI::Commands::EC2::CreateSecurityGroup.new
        create_sec_grps.group_name(@var_sec_group_name).vpc_id(@var_vpc_id).description("Description")
        create_sec_grps.aws.output(@var_output_json).region(var_region)
        expect(@shellout).to receive(:cli).with(create_sec_grps.aws.get_command, nil).ordered.and_return('{ "return": "true" }')

        expect(@textout).to receive(:puts).with(security_group_created)
        begin
          @command_security_group_json_vpcid.declare(@var_sec_group_name, "Description")
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end

    context "check flag provided and security group does not exist" do
      it "then alert user" do

        expect(@shellout).to receive(:cli).with(describe_security_groups_by_name_by_vpcid.aws.get_command, nil).and_return(empty_security_group.get_json)
        expect(@textout).to receive(:puts).with(check_critical_security_group)
        begin
          @command_security_group_json_vpcid_check.declare(@var_sec_group_name, "Description")
        rescue SystemExit => e
          expect(e.status).to eq(2)
        end
      end
    end

    context "check flag provided and subnet exists" do
      it "check passes" do
        expect(@shellout).to receive(:cli).with(describe_security_groups_by_name_by_vpcid.aws.get_command, nil).and_return(single_security_group.get_json)
        expect(@textout).to receive(:puts).with(check_ok_security_group)
        begin
          @command_security_group_json_vpcid_check.declare(@var_sec_group_name, "Description")
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end

    context "undo file provided and subnet exists" do
      it "output delete statement to undo file" do
        expect(@undofile).to receive(:prepend).with("zaws security_group delete #{@var_sec_group_name} --region #{var_region} --vpcid #{@var_vpc_id} $XTRA_OPTS", '#Delete security group', 'undo.sh')
        expect(@shellout).to receive(:cli).with(describe_security_groups_by_name_by_vpcid.aws.get_command, nil).ordered.and_return(single_security_group.get_json)
        expect(@textout).to receive(:puts).with(security_group_exists)
        begin
          @command_security_group_json_vpcid_undo.declare(@var_sec_group_name, "Description")
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end

  end

  describe "#id_by_name" do

    it "security group id by group name" do
      expect(@shellout).to receive(:cli).with(describe_security_groups_by_name_by_vpcid.aws.get_command, nil).and_return(single_security_group.get_json)
      expect(@textout).to receive(:puts).with(@var_security_group_id)
      @aws.ec2.security_group.id_by_name(var_region, @textout, nil, @var_vpc_id, @var_sec_group_name)
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
      net_interfaces=net_interfaces.network_interface_id(0, "eni-1234568").groups(0, security_groups)
      instances = instances.instance_id(0, "i-12345678")
      instances = instances.security_groups(0, security_groups)
      instances = instances.network_interfaces(0, net_interfaces)
      instances_raw=instances.get_json

      security_groups = ZAWS::External::AWSCLI::Generators::Result::EC2::SecurityGroups.new
      security_groups = security_groups.group_name(0, "default").vpc_id(0, "vpc-1f6bb57a").owner_id(0, "123456789012").group_id(0, "sg-B2345678")
      security_groups = security_groups.group_name(1, "my_unused_group").vpc_id(1, "vpc-12345678").owner_id(1, "123456789012").group_id(1, "sg-A2345678")
      security_groups_filtered =security_groups.get_json.gsub(/\s+/, '')

      expect(@aws.ec2.security_group.filter_groups_by_instances(security_groups_raw, instances_raw)).to eq(security_groups_filtered)

    end
  end

end
   
