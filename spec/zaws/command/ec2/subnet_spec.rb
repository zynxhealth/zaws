require 'spec_helper'

describe ZAWS::Services::EC2::Subnet do

  let(:vap_cidr) { "10.0.0.0/24" }

  let(:vap_vpcid) { "vpc-XXXXXX" }

  let(:vap_region) { "us-west-1" }

  let(:vap_az) { "us-west-1b" }

  let(:no_action_subnet_exists) { ZAWS::Helper::Output.colorize("No action needed. Subnet exists already.", AWS_consts::COLOR_GREEN) }
  let(:no_action_subnet_not_exists) { ZAWS::Helper::Output.colorize("Subnet does not exist. Skipping deletion.", AWS_consts::COLOR_GREEN) }
  let(:subnet_created) { ZAWS::Helper::Output.colorize("Subnet created.", AWS_consts::COLOR_YELLOW) }
  let(:subnet_deleted) { ZAWS::Helper::Output.colorize("Subnet deleted.", AWS_consts::COLOR_YELLOW) }
  let(:check_critical_subnet) { ZAWS::Helper::Output.colorize("CRITICAL: Subnet Does Not Exist.", AWS_consts::COLOR_RED) }
  let(:check_ok_subnet) { ZAWS::Helper::Output.colorize("OK: Subnet Exists.", AWS_consts::COLOR_GREEN) }

  let(:aws_create_subnet) {
    create_subnets = ZAWS::External::AWSCLI::Commands::EC2::CreateSubnet.new
    aws_command = ZAWS::External::AWSCLI::Commands::AWS.new
    create_subnets = create_subnets.vpc_id(vap_vpcid).cidr(vap_cidr).availability_zone(vap_az)
    aws_command.output("json").region(vap_region).subcommand(create_subnets)
  }

  let(:aws_delete_subnet) {
    delete_subnet = ZAWS::External::AWSCLI::Commands::EC2::DeleteSubnet.new
    delete_subnet.subnet_id("subnet-YYYYYY")
    delete_subnet.aws.region(vap_region).subcommand(delete_subnet)
  }

  let(:aws_desc_subnets_by_vpcid_and_cidr) {
    desc_subnets = ZAWS::External::AWSCLI::Commands::EC2::DescribeSubnets.new
    desc_subnets.filter.vpc_id(vap_vpcid).cidr(vap_cidr)
    desc_subnets.aws.output("json").region(vap_region)
  }

  let(:aws_desc_subnets_by_vpcid_and_cidr_2) {
    desc_subnets = ZAWS::External::AWSCLI::Commands::EC2::DescribeSubnets.new
    desc_subnets.filter.vpc_id(vap_vpcid).cidr("10.0.1.0/24")
    desc_subnets.aws.output("json").region(vap_region)
  }

  let(:aws_desc_subnets_table) {
    desc_subnets = ZAWS::External::AWSCLI::Commands::EC2::DescribeSubnets.new
    desc_subnets.aws.output("table").region(vap_region)
  }

  let(:aws_desc_subnets_json) {
    desc_subnets = ZAWS::External::AWSCLI::Commands::EC2::DescribeSubnets.new
    desc_subnets.aws.output("json").region(vap_region)
  }

  let(:aws_desc_subnets_json_by_vpcid) {
    desc_subnets = ZAWS::External::AWSCLI::Commands::EC2::DescribeSubnets.new
    desc_subnets.filter.vpc_id(vap_vpcid)
    desc_subnets.aws.output("json").region(vap_region)
  }

  before(:each) {
    options = {:region => vap_region,
               :verbose => false,
               :availabilitytimeout => 30,
               :check => false,
               :undofile => false,
               :viewtype => 'table'
    }

    options_viewtype_json = {:region => vap_region,
                             :verbose => false,
                             :availabilitytimeout => 30,
                             :check => false,
                             :undofile => false,
                             :viewtype => 'json',
                             :vpcid => 'vpc-XXXXXX'}

    options_check = {:region => vap_region,
                     :verbose => false,
                     :availabilitytimeout => 30,
                     :check => true,
                     :undofile => false,
                     :viewtype => 'json'}

    options_undofile = {:region => vap_region,
                        :verbose => false,
                        :availabilitytimeout => 30,
                        :check => false,
                        :undofile => "undo.txt"}

    @textout=double('output')
    @shellout=double('ZAWS::Helper::Shell')
    @undofile=double('ZAWS::Helper::ZFile')
    @command_subnet = ZAWS::Command::Subnet.new([], options, {})
    @command_subnet_viewtype_json= ZAWS::Command::Subnet.new([], options_viewtype_json, {})
    @command_subnet_check = ZAWS::Command::Subnet.new([], options_check, {})
    @command_subnet_undofile = ZAWS::Command::Subnet.new([], options_undofile, {})
    @aws=ZAWS::AWS.new(@shellout, ZAWS::AWSCLI.new(@shellout, true), @undofile)
    @command_subnet.aws=@aws
    @command_subnet.out=@textout
    @command_subnet.print_exit_code = true
    @command_subnet_check.aws=@aws
    @command_subnet_check.out=@textout
    @command_subnet_check.print_exit_code = true
    @command_subnet_undofile.aws=@aws
    @command_subnet_undofile.out=@textout
    @command_subnet_undofile.print_exit_code = true
    @command_subnet_viewtype_json.aws=@aws
    @command_subnet_viewtype_json.out=@textout
    @command_subnet_viewtype_json.print_exit_code = true

    subnets = ZAWS::External::AWSCLI::Generators::Result::EC2::Subnets.new
    subnets = subnets.vpc_id(0, vap_vpcid).cidr_block(0, vap_cidr).map_public_ip_on_launch(0, false)
    subnets = subnets.default_for_az(0, false).state(0, "available").subnet_id(0, "subnet-YYYYYY")
    @subnets_exists = subnets.available_ip_address_count(0, 251)

    subnets = ZAWS::External::AWSCLI::Generators::Result::EC2::Subnets.new
    subnets = subnets.vpc_id(0, vap_vpcid).cidr_block(0, "10.0.1.0/24").map_public_ip_on_launch(0, false)
    subnets = subnets.default_for_az(0, false).state(0, "available").subnet_id(0, "subnet-ZZZZZZ")
    @subnets_exists2 = subnets.available_ip_address_count(0, 251)

    subnets = ZAWS::External::AWSCLI::Generators::Result::EC2::Subnets.new
    subnets = subnets.add(@subnets_exists2)
    subnets = subnets.add(@subnets_exists)
    @subnet_exists3 =subnets

    @subnets_not_exists = ZAWS::External::AWSCLI::Generators::Result::EC2::Subnets.new

  }

  describe "#view" do
    it "view subnets, table view" do
      expect(@shellout).to receive(:cli).with(aws_desc_subnets_table.get_command, @verbose).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @command_subnet.view
    end

    it "view subnets,  json view" do
      expect(@shellout).to receive(:cli).with(aws_desc_subnets_json.get_command, @verbose).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @command_subnet_check.view
    end

    it "view subnets, json view, specific VPC" do
      expect(@shellout).to receive(:cli).with(aws_desc_subnets_json_by_vpcid.get_command, @verbose).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @command_subnet_viewtype_json.view
    end
  end

  describe "#exists" do
    context "in which the target subnet has been created" do
      it "returns true" do
        expect(@shellout).to receive(:cli).with(aws_desc_subnets_by_vpcid_and_cidr.get_command, nil).and_return(@subnets_exists.get_json)
        expect(@textout).to receive(:puts).with("true")
        @command_subnet.exists(vap_cidr, vap_vpcid)
      end
    end

    context "in which the target subnet has NOT been created" do
      it "returns false" do
        expect(@shellout).to receive(:cli).with(aws_desc_subnets_by_vpcid_and_cidr.get_command, @verbose).and_return(@subnets_not_exists.get_json)
        expect(@textout).to receive(:puts).with('false')
        @command_subnet.exists(vap_cidr, vap_vpcid)
      end
    end
  end

  describe "#declare" do
    context "in which the target subnet has been created" do
      it "does not attempt to create it, instead informs caller of it existance" do
        expect(@shellout).to receive(:cli).with(aws_desc_subnets_by_vpcid_and_cidr.get_command, @verbose).and_return(@subnets_exists.get_json)
        expect(@textout).to receive(:puts).with(no_action_subnet_exists)
        expect(@textout).to receive(:puts).with(0)
        @command_subnet.declare(vap_cidr, vap_az, vap_vpcid)
      end
    end

    context "in which the target subnet has NOT been created" do
      it "then creates it" do
        var_subnet_available= '{ "Subnet": { "State": "available" } }'
        expect(@shellout).to receive(:cli).with(aws_desc_subnets_by_vpcid_and_cidr.get_command, nil).and_return(@subnets_not_exists.get_json)
        expect(@shellout).to receive(:cli).with(aws_create_subnet.get_command, nil).and_return(var_subnet_available)
        expect(@textout).to receive(:puts).with(subnet_created)
        expect(@textout).to receive(:puts).with(0)
        @command_subnet.declare(vap_cidr, vap_az, vap_vpcid)
      end
    end

    context "subnet not immediately available after creation" do
      it "declare subnet and wait through pending state" do
        var_subnet_pending= '{ "Subnet": { "State": "pending" } }'
        var_subnet_available= '{ "Subnet": { "State": "available" } }'
        expect(@shellout).to receive(:cli).with(anything(), anything()).and_return(@subnets_not_exists.get_json, var_subnet_pending, var_subnet_available)
        expect(@textout).to receive(:puts).with(subnet_created)
        expect(@textout).to receive(:puts).with(0)
        @command_subnet.declare(vap_cidr, vap_az, vap_vpcid)
      end
    end

    context "undo file provided and subnet exists" do
      it "output delete statement to undo file" do
        expect(@undofile).to receive(:prepend).with("zaws subnet delete #{vap_cidr} #{vap_vpcid} --region us-west-1 $XTRA_OPTS", '#Delete subnet', 'undo.txt')
        expect(@shellout).to receive(:cli).with(aws_desc_subnets_by_vpcid_and_cidr.get_command, nil).and_return(@subnets_exists.get_json)
        expect(@textout).to receive(:puts).with(no_action_subnet_exists)
        expect(@textout).to receive(:puts).with(0)
        @command_subnet_undofile.declare(vap_cidr, vap_az, vap_vpcid)
      end
    end

    context "check flag provided and subnet does not exist" do
      it "then alert user" do
        expect(@shellout).to receive(:cli).with(aws_desc_subnets_by_vpcid_and_cidr.get_command, nil).and_return(@subnets_not_exists.get_json)
        expect(@textout).to receive(:puts).with(check_critical_subnet)
        expect(@textout).to receive(:puts).with(2)
        @command_subnet_check.declare(vap_cidr, vap_az, vap_vpcid)
      end
    end

    context "check flag provided and subnet exists" do
      it "check passes" do
        expect(@shellout).to receive(:cli).with(aws_desc_subnets_by_vpcid_and_cidr.get_command, nil).and_return(@subnets_exists.get_json)
        expect(@textout).to receive(:puts).with(check_ok_subnet)
        expect(@textout).to receive(:puts).with(0)
        @command_subnet_check.declare(vap_cidr, vap_az, vap_vpcid)
      end
    end
  end

  describe "#delete" do
    context "in which the target subnet has NOT been created" do
      it "then skip deletion" do
        expect(@shellout).to receive(:cli).with(aws_desc_subnets_by_vpcid_and_cidr.get_command, nil).and_return(@subnets_not_exists.get_json)
        expect(@textout).to receive(:puts).with(no_action_subnet_not_exists)
        @command_subnet.delete(vap_cidr, vap_vpcid)
      end
    end

    context "in which the target subnet has been created" do
      it "does not attempt to create it, instead informs caller of it existance" do
        expect(@shellout).to receive(:cli).with(aws_desc_subnets_by_vpcid_and_cidr.get_command, nil).and_return(@subnets_exists.get_json)
        expect(@shellout).to receive(:cli).with(aws_delete_subnet.get_command, nil).and_return('{ "return": "true" }')
        expect(@textout).to receive(:puts).with(subnet_deleted)
        @command_subnet.delete(vap_cidr, vap_vpcid)
      end
    end
  end

  describe "#id_array_by_cidrblock_array" do
    it "Provides an array of subnet ids if given an array of subnet cidr blocks" do
      expect(@shellout).to receive(:cli).with(aws_desc_subnets_by_vpcid_and_cidr.get_command, nil).and_return(@subnets_exists.get_json)
      expect(@shellout).to receive(:cli).with(aws_desc_subnets_by_vpcid_and_cidr_2.get_command, nil).and_return(@subnets_exists2.get_json)
      expect(@aws.ec2.subnet.id_array_by_cidrblock_array('us-west-1', nil, 'vpc-XXXXXX', ["10.0.0.0/24", "10.0.1.0/24"])).to eql(["subnet-YYYYYY", "subnet-ZZZZZZ"])
    end
  end

  describe "#id_by_ip" do
    it "get subnet id by ip" do
      expect(@shellout).to receive(:cli).with(aws_desc_subnets_json_by_vpcid.get_command, nil).and_return(@subnets_exists.get_json)
      expect(@aws.ec2.subnet.id_by_ip('us-west-1', nil, 'vpc-XXXXXX', '10.0.0.24')).to eq('subnet-YYYYYY')
    end
  end

  describe "#id_by_cidrblock" do
    it "subnet id by cidr block" do
      expect(@shellout).to receive(:cli).with(aws_desc_subnets_by_vpcid_and_cidr.get_command, nil).and_return(@subnets_exists.get_json)
      expect(@aws.ec2.subnet.id_by_cidrblock('us-west-1', nil, 'vpc-XXXXXX', '10.0.0.0/24')).to eq('subnet-YYYYYY')
    end
  end

end


