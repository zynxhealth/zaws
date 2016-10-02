require 'spec_helper'

describe ZAWS::Services::EC2::RouteTable do

  let(:route_table_created) { ZAWS::Helper::Output.colorize("Route table created with external id: my_route_table.", AWS_consts::COLOR_YELLOW) }
  let(:route_table_exist) { ZAWS::Helper::Output.colorize("Route table exists already. Skipping Creation.", AWS_consts::COLOR_GREEN) }
  let(:route_table_not_deleted) { ZAWS::Helper::Output.colorize("Route table does not exist. Skipping deletion.", AWS_consts::COLOR_GREEN) }
  let(:route_table_deleted) { ZAWS::Helper::Output.colorize("Route table deleted.", AWS_consts::COLOR_YELLOW) }
  let(:route_table_ok) { ZAWS::Helper::Output.colorize("OK: Route table exists.", AWS_consts::COLOR_GREEN) }
  let(:route_table_critical) { ZAWS::Helper::Output.colorize("CRITICAL: Route table does not exist.", AWS_consts::COLOR_RED) }

  let(:route_created) { ZAWS::Helper::Output.colorize("Route created to instance.", AWS_consts::COLOR_YELLOW) }
  let(:route_not_created) { ZAWS::Helper::Output.colorize("Route not created to instance. Skip creation.", AWS_consts::COLOR_GREEN) }

  let(:ok_route_propagation) { ZAWS::Helper::Output.colorize("OK: Route propagation from gateway enabled.", AWS_consts::COLOR_GREEN) }
  let(:critical_route_propagation) { ZAWS::Helper::Output.colorize("CRITICAL: Route propagation from gateway not enabled.", AWS_consts::COLOR_RED) }

  let(:ok_declare_route) { ZAWS::Helper::Output.colorize("OK: Route to instance exists.", AWS_consts::COLOR_GREEN) }
  let(:critical_declare_route) { ZAWS::Helper::Output.colorize("CRITICAL: Route to instance does not exist.", AWS_consts::COLOR_RED) }

  let(:ok_assoc_subnet) { ZAWS::Helper::Output.colorize("OK: Route table association to subnet exists.", AWS_consts::COLOR_GREEN) }
  let(:critical_assoc_subnet) { ZAWS::Helper::Output.colorize("CRITICAL: Route table association to subnet does not exist.", AWS_consts::COLOR_RED) }

  let(:ok_declare_route_to_gateway) { ZAWS::Helper::Output.colorize("OK: Route to gateway exists.", AWS_consts::COLOR_GREEN) }
  let(:critical_declare_route_to_gateway) { ZAWS::Helper::Output.colorize("CRITICAL: Route to gateway does not exist.", AWS_consts::COLOR_RED) }

  let(:route_not_deleted) { ZAWS::Helper::Output.colorize("Route does not exist. Skipping deletion.", AWS_consts::COLOR_GREEN) }
  let(:route_deleted) { ZAWS::Helper::Output.colorize("Route deleted.", AWS_consts::COLOR_YELLOW) }

  let(:route_to_gateway_not_created) { ZAWS::Helper::Output.colorize("Route to gateway exists. Skipping creation.", AWS_consts::COLOR_GREEN) }
  let(:route_to_gateway_created) { ZAWS::Helper::Output.colorize("Route created to gateway.", AWS_consts::COLOR_YELLOW) }

  let(:route_propagated_to_gateway) { ZAWS::Helper::Output.colorize("Route propagation from gateway enabled.", AWS_consts::COLOR_YELLOW) }
  let(:route_propagated_to_gateway_already) { ZAWS::Helper::Output.colorize("Route propagation from gateway already enabled. Skipping propagation.", AWS_consts::COLOR_GREEN) }

  let(:delete_route_propagation_from_gateway) { ZAWS::Helper::Output.colorize("Deleted route propagation from gateway.", AWS_consts::COLOR_YELLOW) }
  let(:not_delete_route_propagation_from_gateway) { ZAWS::Helper::Output.colorize("Route propagation from gateway does not exist, skipping deletion.", AWS_consts::COLOR_GREEN) }

  let(:assoc_subnet_skipped) { ZAWS::Helper::Output.colorize("Route table already associated to subnet. Skipping association.", AWS_consts::COLOR_GREEN) }
  let(:assoc_subnet_executed) { ZAWS::Helper::Output.colorize("Route table associated to subnet.", AWS_consts::COLOR_YELLOW) }

  let(:assoc_subnet_not_deleted) { ZAWS::Helper::Output.colorize("Route table association to subnet not deleted because it does not exist.", AWS_consts::COLOR_GREEN) }
  let(:assoc_subnet_deleted) { ZAWS::Helper::Output.colorize("Route table association to subnet deleted.", AWS_consts::COLOR_YELLOW) }

  let(:region) { "us-west-1" }
  let(:security_group_name) { "my_security_group_name" }
  let(:security_group_id) { "sg-abcd1234" }
  let(:output_json) { "json" }
  let(:output_table) { "table" }
  let(:vpc_id) { "my_vpc_id" }
  let(:externalid_route_table) { "my_route_table" }
  let(:route_table_id) { "rtb-XXXXXXX" }
  let(:cidr) { "10.0.0.0/24" }
  let(:vgw) { 'vgw-????????' }
  let(:external_id) { "my_instance" }
  let(:instance_id) { "i-12345678" }
  let(:gateway_id) { "igw-XXXXXXX" }
  let(:subnet_id) { "subnet-YYYYYY" }
  let(:route_table_association_id) { "rtbassoc-????????" }

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
    instances.instance_id(0, instance_id).tags(0, tags)
  }

  let(:empty_route_tables) {
    ZAWS::External::AWSCLI::Generators::Result::EC2::RouteTables.new
  }

  let(:single_route_tables) {
    single_route_table=ZAWS::External::AWSCLI::Generators::Result::EC2::RouteTables.new
    single_route_table.vpc_id(0, vpc_id).route_table_id(0, route_table_id)
  }

  let(:single_route_tables_with_gateway) {
    routes=ZAWS::External::AWSCLI::Generators::Result::EC2::Routes.new
    routes.gateway_id(0, gateway_id)
    routes.destination_cidr_block(0, cidr)
    single_route_table=ZAWS::External::AWSCLI::Generators::Result::EC2::RouteTables.new
    single_route_table.vpc_id(0, vpc_id).route_table_id(0, route_table_id).routes(0, routes)
  }

  let(:single_route_tables_with_instance) {
    routes=ZAWS::External::AWSCLI::Generators::Result::EC2::Routes.new
    routes.instance_id(0, instance_id)
    routes.destination_cidr_block(0, cidr)
    single_route_table=ZAWS::External::AWSCLI::Generators::Result::EC2::RouteTables.new
    single_route_table.vpc_id(0, vpc_id).route_table_id(0, route_table_id).routes(0, routes)
  }

  let(:single_route_tables_with_prop_gateway) {
    virtualgw = ZAWS::External::AWSCLI::Generators::Result::EC2::VirtualGateway.new
    single_route_table=ZAWS::External::AWSCLI::Generators::Result::EC2::RouteTables.new
    virtualgw.gateway_id(vgw)
    single_route_table.vpc_id(0, vpc_id).route_table_id(0, route_table_id).propagate_to_virtual_gateway(0, virtualgw)
  }

  let (:describe_route_tables) {
    tags = ZAWS::External::AWSCLI::Generators::Result::EC2::Tags.new
    tags = tags.add("externalid", externalid_route_table)
    desc_route_tables = ZAWS::External::AWSCLI::Commands::EC2::DescribeRouteTables.new
    desc_route_tables.filter.vpc_id(vpc_id).tags(tags)
    desc_route_tables.aws.output(output_json).region(region)
    desc_route_tables
  }

  let(:create_route_table) {
    create_route_table = ZAWS::External::AWSCLI::Commands::EC2::CreateRouteTable.new
    create_route_table.vpc_id(vpc_id)
    create_route_table.aws.region(region)
    create_route_table
  }

  let(:delete_route_table) {
    drt = ZAWS::External::AWSCLI::Commands::EC2::DeleteRouteTable.new
    drt.route_table_id(route_table_id)
    drt.aws.region(region)
    drt
  }

  let(:create_tags) {
    tags = ZAWS::External::AWSCLI::Generators::Result::EC2::Tags.new
    tags = tags.add("externalid", externalid_route_table)
    create_tags = ZAWS::External::AWSCLI::Commands::EC2::CreateTags.new
    create_tags.resource(route_table_id).tags(tags)
    create_tags.aws.region(region)
    create_tags
  }

  let(:single_subnets) {
    subnets = ZAWS::External::AWSCLI::Generators::Result::EC2::Subnets.new
    subnets.subnet_id(0, subnet_id).route_table_association_id(0,route_table_association_id)
  }

  let(:single_route_tables_with_associations) {
    single_route_table=ZAWS::External::AWSCLI::Generators::Result::EC2::RouteTables.new
    single_route_table.vpc_id(0, vpc_id).route_table_id(0, route_table_id).associate_subnets(0, single_subnets)
  }

  let(:describe_subnets) {
    desc_subnets = ZAWS::External::AWSCLI::Commands::EC2::DescribeSubnets.new
    desc_subnets.filter.vpc_id(vpc_id).cidr(cidr)
    desc_subnets.aws.output("json").region(region)
    desc_subnets
  }

  let(:create_route) {
    cr = ZAWS::External::AWSCLI::Commands::EC2::CreateRoute.new
    cr.aws.region(region)
    cr.route_table_id(route_table_id).destination_cidr_block(cidr).instance_id(instance_id)
  }

  let(:create_route_to_gateway) {
    cr = ZAWS::External::AWSCLI::Commands::EC2::CreateRoute.new
    cr.aws.region(region)
    cr.route_table_id(route_table_id).destination_cidr_block(cidr).gateway_id(gateway_id)
  }

  let(:associate_route_table) {
    art = ZAWS::External::AWSCLI::Commands::EC2::AssociateRouteTable.new
    art.aws.region(region)
    art.route_table_id(route_table_id).subnet_id(subnet_id)
  }

  let(:disassociate_route_table) {
    art = ZAWS::External::AWSCLI::Commands::EC2::DisassociateRouteTable.new
    art.aws.region(region)
    art.association_id(route_table_association_id)
  }

  let(:delete_route) {
    cr = ZAWS::External::AWSCLI::Commands::EC2::DeleteRoute.new
    cr.aws.region(region)
    cr.route_table_id(route_table_id).destination_cidr_block(cidr)
  }

  let(:create_route_to_gateway) {
    cr = ZAWS::External::AWSCLI::Commands::EC2::CreateRoute.new
    cr.aws.region(region)
    cr.route_table_id(route_table_id).destination_cidr_block(cidr).gateway_id(gateway_id)
  }

  let(:enable_vgw_route_propagation) {
    evrp = ZAWS::External::AWSCLI::Commands::EC2::EnableVgwRoutePropagation.new
    evrp.aws.region(region)
    evrp.route_table_id(route_table_id).gateway_id('vgw-????????')
  }

  let(:disable_vgw_route_propagation) {
    dvrp = ZAWS::External::AWSCLI::Commands::EC2::DisableVgwRoutePropagation.new
    dvrp.aws.region(region)
    dvrp.route_table_id(route_table_id).gateway_id('vgw-????????')
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

    options = {:region => @var_region,
               :verbose => false,
               :check => false,
               :undofile => false
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
    @command_route_table_noview = ZAWS::Command::Route_Table.new([], options, {})
    @command_route_table_noview.aws=@aws
    @command_route_table_noview.out=@textout
    @command_route_table_noview.print_exit_code = true

    @command_route_table = ZAWS::Command::Route_Table.new([], options_table, {})
    @command_route_table.aws=@aws
    @command_route_table.out=@textout
    @command_route_table.print_exit_code = true
    @command_route_table_json = ZAWS::Command::Route_Table.new([], options_json, {})
    @command_route_table_json.aws=@aws
    @command_route_table_json.out=@textout
    @command_route_table_json.print_exit_code = true
    @command_route_table_json_vpcid = ZAWS::Command::Route_Table.new([], options_json_vpcid, {})
    @command_route_table_json_vpcid.aws=@aws
    @command_route_table_json_vpcid.out=@textout
    @command_route_table_json_vpcid.print_exit_code = true

    @command_route_table_json_vpcid_check = ZAWS::Command::Route_Table.new([], options_json_vpcid_check, {})
    @command_route_table_json_vpcid_check.aws=@aws
    @command_route_table_json_vpcid_check.out=@textout
    @command_route_table_json_vpcid_check.print_exit_code = true

    @command_route_table_json_vpcid_undo = ZAWS::Command::Route_Table.new([], options_json_vpcid_undo, {})
    @command_route_table_json_vpcid_undo.aws=@aws
    @command_route_table_json_vpcid_undo.out=@textout
    @command_route_table_json_vpcid_undo.print_exit_code = true

  }

  describe "#view" do

    it "Get route table in a human readable table." do
      desc_route_tbls = ZAWS::External::AWSCLI::Commands::EC2::DescribeRouteTables.new
      aws_command = ZAWS::External::AWSCLI::Commands::AWS.new
      aws_command = aws_command.output(@var_output_table).region(@var_region).subcommand(desc_route_tbls)
      expect(@shellout).to receive(:cli).with(aws_command.get_command, nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @command_route_table.view
    end

    it "Get route table in JSON form" do
      desc_route_tbls = ZAWS::External::AWSCLI::Commands::EC2::DescribeRouteTables.new
      aws_command = ZAWS::External::AWSCLI::Commands::AWS.new
      aws_command = aws_command.output(@var_output_json).region(@var_region).subcommand(desc_route_tbls)
      expect(@shellout).to receive(:cli).with(aws_command.get_command, nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @command_route_table_json.view
    end

    it "Get route table from specified vpcid" do
      desc_route_tbls = ZAWS::External::AWSCLI::Commands::EC2::DescribeRouteTables.new
      desc_route_tbls.filter.vpc_id(@var_vpc_id)
      desc_route_tbls.aws.output(@var_output_json).region(@var_region).subcommand(desc_route_tbls)
      expect(@shellout).to receive(:cli).with(desc_route_tbls.aws.get_command, nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @command_route_table_json_vpcid.view
    end

  end

  describe "#exists_by_external_id" do
    context "route table does not exist" do
      it "Determine a route table DOES NOT exists by external id" do
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(empty_route_tables.get_json)
        expect(@textout).to receive(:puts).with('false')
        @command_route_table_json_vpcid.exists_by_external_id(externalid_route_table)
      end
    end
    context "route table does exist" do
      it "Determine a route table exists by external id" do
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables.get_json)
        expect(@textout).to receive(:puts).with('true')
        @command_route_table_json_vpcid.exists_by_external_id(externalid_route_table)
      end
    end
  end

  describe "#declare" do

    context "route table does not exist by external id" do
      it "create route table by external id" do
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(empty_route_tables.get_json)
        expect(@shellout).to receive(:cli).with(create_route_table.aws.get_command, nil).and_return(single_route_tables.get_json_single_route_table(0))
        expect(@shellout).to receive(:cli).with(create_tags.aws.get_command, nil).and_return('{	"return": "true" }')
        expect(@textout).to receive(:puts).with(route_table_created)
        begin
          @command_route_table_json_vpcid.declare(externalid_route_table, vpc_id)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end
    context "route table does not exist by external id and check flag present" do
      it "check returns critical" do
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(empty_route_tables.get_json)
        expect(@textout).to receive(:puts).with(route_table_critical)
        begin
          @command_route_table_json_vpcid_check.declare(externalid_route_table, vpc_id)
        rescue SystemExit => e
          expect(e.status).to eq(2)
        end
      end
    end

    context "route table does exist" do
      it "does not create the route table" do
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables.get_json)
        expect(@textout).to receive(:puts).with(route_table_exist)
        begin
          @command_route_table_json_vpcid.declare(externalid_route_table, vpc_id)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end
    context "route table does exist and check flag present" do
      it "check returns ok" do
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables.get_json)
        expect(@textout).to receive(:puts).with(route_table_ok)
        begin
          @command_route_table_json_vpcid_check.declare(externalid_route_table, vpc_id)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end


    context "undo file provided and route table exists" do
      it "output delete statement to undo file" do
        expect(@undofile).to receive(:prepend).with("zaws route_table delete #{externalid_route_table} --region #{region} --vpcid #{vpc_id} $XTRA_OPTS", '#Delete route table', 'undo.sh')
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).ordered.and_return(single_route_tables.get_json)
        expect(@textout).to receive(:puts).with(route_table_exist)
        begin
          @command_route_table_json_vpcid_undo.declare(externalid_route_table, vpc_id)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end

  end

  describe "#delete" do
    context "route table does not exist by external id" do
      it "does nothing" do
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(empty_route_tables.get_json)
        expect(@textout).to receive(:puts).with(route_table_not_deleted)
        @command_route_table_json_vpcid.delete(externalid_route_table)
      end
    end
    context "route table does exist by external id" do
      it "delete route table" do
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables.get_json)
        expect(@shellout).to receive(:cli).with(delete_route_table.aws.get_command, nil).and_return('{	"return": "true" }')
        expect(@textout).to receive(:puts).with(route_table_deleted)
        @command_route_table_json_vpcid.delete(externalid_route_table)
      end
    end
  end


  describe "#subnet_assoc_exists" do
    context "subnet is associated to a route table " do
      it "returns true" do
        expect(@shellout).to receive(:cli).with(describe_subnets.aws.get_command, nil).and_return(single_subnets.get_json)
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables_with_associations.get_json)
        expect(@textout).to receive(:puts).with('true')
        @command_route_table_json_vpcid.subnet_assoc_exists(externalid_route_table, cidr)
      end
    end
    context "subnet is associated to a route table " do
      it "returns true" do
        expect(@shellout).to receive(:cli).with(describe_subnets.aws.get_command, nil).and_return(single_subnets.get_json)
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables.get_json)
        expect(@textout).to receive(:puts).with('false')
        @command_route_table_json_vpcid.subnet_assoc_exists(externalid_route_table, cidr)
      end
    end
  end

  describe "#delete_assoc_subnet" do
    context "Route table association to subnet does not exists." do
      it "Skip deletion" do
        expect(@shellout).to receive(:cli).with(describe_subnets.aws.get_command, nil).and_return(single_subnets.get_json)
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables.get_json)
        expect(@textout).to receive(:puts).with(assoc_subnet_not_deleted)
        begin
          @command_route_table_json_vpcid.delete_assoc_subnet(externalid_route_table, cidr)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end
    context "Route table association to subnet exists." do
      it "Delete association" do
        expect(@shellout).to receive(:cli).with(describe_subnets.aws.get_command, nil).and_return(single_subnets.get_json)
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables_with_associations.get_json)
        expect(@shellout).to receive(:cli).with(disassociate_route_table.aws.get_command, nil).and_return('{	"return" : "true" }')
        expect(@textout).to receive(:puts).with(assoc_subnet_deleted)
        begin
          @command_route_table_json_vpcid.delete_assoc_subnet(externalid_route_table, cidr)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end
  end

  describe "#assoc_subnet" do
    context "Route table association to subnet exists." do
      it "skips association" do
        expect(@shellout).to receive(:cli).with(describe_subnets.aws.get_command, nil).and_return(single_subnets.get_json)
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables_with_associations.get_json)
        expect(@textout).to receive(:puts).with(assoc_subnet_skipped)
        begin
          @command_route_table_json_vpcid.assoc_subnet(externalid_route_table, cidr)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end
    context "Route table association to subnet does not exists." do
      it "associate route table to subnet" do
        expect(@shellout).to receive(:cli).with(describe_subnets.aws.get_command, nil).and_return(single_subnets.get_json)
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables.get_json)
        expect(@shellout).to receive(:cli).with(associate_route_table.aws.get_command, nil).and_return('{	"AssociationId": "rtbassoc-???????" }')
        expect(@textout).to receive(:puts).with(assoc_subnet_executed)
        begin
          @command_route_table_json_vpcid.assoc_subnet(externalid_route_table, cidr)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end
    context "Undo file set, and route table association to subnet exists." do
      it "Writes to undo file skips association" do
        expect(@undofile).to receive(:prepend).with("zaws route_table delete_assoc_subnet #{externalid_route_table} #{cidr} --region #{region} --vpcid #{vpc_id} $XTRA_OPTS", '#Delete route table association to subnet', 'undo.sh')
        expect(@shellout).to receive(:cli).with(describe_subnets.aws.get_command, nil).and_return(single_subnets.get_json)
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables_with_associations.get_json)
        expect(@textout).to receive(:puts).with(assoc_subnet_skipped)
        begin
          @command_route_table_json_vpcid_undo.assoc_subnet(externalid_route_table, cidr)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end
    context "Route table association to subnet exists." do
      it "return ok" do
        expect(@shellout).to receive(:cli).with(describe_subnets.aws.get_command, nil).and_return(single_subnets.get_json)
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables_with_associations.get_json)
        expect(@textout).to receive(:puts).with(ok_assoc_subnet)
        begin
          @command_route_table_json_vpcid_check.assoc_subnet(externalid_route_table, cidr)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end
    context "Route table association to subnet does not exists." do
      it "return critical" do
        expect(@shellout).to receive(:cli).with(describe_subnets.aws.get_command, nil).and_return(single_subnets.get_json)
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables.get_json)
        expect(@textout).to receive(:puts).with(critical_assoc_subnet)
        begin
          @command_route_table_json_vpcid_check.assoc_subnet(externalid_route_table, cidr)
        rescue SystemExit => e
          expect(e.status).to eq(2)
        end
      end
    end
  end

  describe "#propagation_exists_from_gateway" do
    context "route table propagates to virtual gatway already" do
      it "return true" do
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables_with_prop_gateway.get_json)
        expect(@textout).to receive(:puts).with('true')
        @command_route_table_json_vpcid_check.propagation_exists_from_gateway(externalid_route_table, vgw)
      end
    end
    context "check flag is set and route table is not propagating to virtual gatway" do
      it "check critical" do
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables.get_json)
        expect(@textout).to receive(:puts).with('false')
        @command_route_table_json_vpcid_check.propagation_exists_from_gateway(externalid_route_table, vgw)
      end
    end
  end

  describe "#delete_propagation_from_gateway" do
    context "route table propagates to virtual gatway currently" do
      it "delete propagation" do
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables_with_prop_gateway.get_json)
        expect(@shellout).to receive(:cli).with(disable_vgw_route_propagation.aws.get_command, nil).and_return('{	"return": "true" }')
        expect(@textout).to receive(:puts).with(delete_route_propagation_from_gateway)
        begin
          @command_route_table_json_vpcid.delete_propagation_from_gateway(externalid_route_table, vgw)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end

      end
    end
    context "route table is not propagating to virtual gatway" do
      it "skip deletion" do
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables.get_json)
        expect(@textout).to receive(:puts).with(not_delete_route_propagation_from_gateway)
        begin
          @command_route_table_json_vpcid.delete_propagation_from_gateway(externalid_route_table, vgw)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end
  end

  describe "#declare_propagation_from_gateway" do
    context "undo flag specified and route table propagates to virtual gatway already" do
      it "undo file written to" do
        expect(@undofile).to receive(:prepend).with("zaws route_table delete_propagation_from_gateway my_route_table #{vgw} --region #{region} --vpcid #{vpc_id} $XTRA_OPTS", '#Delete route propagation', 'undo.sh')
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables_with_prop_gateway.get_json)
        expect(@textout).to receive(:puts).with(route_propagated_to_gateway_already)
        begin
          @command_route_table_json_vpcid_undo.declare_propagation_from_gateway(externalid_route_table, vgw)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end

      end
    end
    context "route table propagates to virtual gatway already" do
      it "skip propagation" do
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables_with_prop_gateway.get_json)
        expect(@textout).to receive(:puts).with(route_propagated_to_gateway_already)
        begin
          @command_route_table_json_vpcid.declare_propagation_from_gateway(externalid_route_table, vgw)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end

      end
    end
    context "route table is not propagating to virtual gatway" do
      it "setup propagation" do
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables.get_json)
        expect(@shellout).to receive(:cli).with(enable_vgw_route_propagation.aws.get_command, nil).and_return('{	"return": "true" }')
        expect(@textout).to receive(:puts).with(route_propagated_to_gateway)
        begin
          @command_route_table_json_vpcid.declare_propagation_from_gateway(externalid_route_table, vgw)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end
    context "check flag is set and route table propagates to virtual gatway already" do
      it "check ok" do
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables_with_prop_gateway.get_json)

        expect(@textout).to receive(:puts).with(ok_route_propagation)
        begin
          @command_route_table_json_vpcid_check.declare_propagation_from_gateway(externalid_route_table, vgw)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end

      end
    end
    context "check flag is set and route table is not propagating to virtual gatway" do
      it "check critical" do
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables.get_json)
        expect(@textout).to receive(:puts).with(critical_route_propagation)
        begin
          @command_route_table_json_vpcid_check.declare_propagation_from_gateway(externalid_route_table, vgw)
        rescue SystemExit => e
          expect(e.status).to eq(2)
        end
      end
    end
  end

  describe "#route_exists_by_instance" do
    context "subnet is associated to a route table " do
      it "returns true" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables_with_instance.get_json)
        expect(@textout).to receive(:puts).with('true')
        @command_route_table_json_vpcid.route_exists_by_instance(externalid_route_table, cidr, external_id)
      end
    end
    context "subnet is associated to a route table " do
      it "returns true" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables.get_json)
        expect(@textout).to receive(:puts).with('false')
        @command_route_table_json_vpcid.route_exists_by_instance(externalid_route_table, cidr, external_id)
      end
    end
  end

  describe "#delete_route" do
    context "route exists" do
      it "delete route" do
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables_with_instance.get_json)
        expect(@shellout).to receive(:cli).with(delete_route.aws.get_command, nil).and_return('{	"return" : "true" }')
        expect(@textout).to receive(:puts).with(route_deleted)
        begin
          @command_route_table_json_vpcid.delete_route(externalid_route_table, cidr)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end

      end
    end
    context "route does not exists" do
      it "skip deletion" do
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables.get_json)
        expect(@textout).to receive(:puts).with(route_not_deleted)
        begin
          @command_route_table_json_vpcid.delete_route(externalid_route_table, cidr)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end

  end

  describe "#declare_route" do
    context "route exists" do
      it "skip route creation" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables_with_instance.get_json)
        expect(@textout).to receive(:puts).with(route_not_created)
        begin
          @command_route_table_json_vpcid.declare_route(externalid_route_table, cidr, external_id)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end

      end
    end
    context "undo file provided and route table exists" do
      it "output delete statement to undo file" do
        expect(@undofile).to receive(:prepend).with("zaws route_table delete_route #{externalid_route_table} #{cidr} --region #{region} --vpcid #{vpc_id} $XTRA_OPTS", '#Delete route', 'undo.sh')
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables_with_instance.get_json)
        expect(@textout).to receive(:puts).with(route_not_created)
        begin
          @command_route_table_json_vpcid_undo.declare_route(externalid_route_table, cidr, external_id)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end

      end
    end
    context "route does not exists" do
      it "create route" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables.get_json)
        expect(@shellout).to receive(:cli).with(create_route.aws.get_command, nil).and_return('{	"return": "true" }')
        expect(@textout).to receive(:puts).with(route_created)
        begin
          @command_route_table_json_vpcid.declare_route(externalid_route_table, cidr, external_id)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end
    context "check flag is set and route exists" do
      it "check ok" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables_with_instance.get_json)
        expect(@textout).to receive(:puts).with(ok_declare_route)
        begin
          @command_route_table_json_vpcid_check.declare_route(externalid_route_table, cidr, external_id)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end

      end
    end
    context "check flag is set and route does not exists" do
      it "check critical" do
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables.get_json)
        expect(@textout).to receive(:puts).with(critical_declare_route)
        begin
          @command_route_table_json_vpcid_check.declare_route(externalid_route_table, cidr, external_id)
        rescue SystemExit => e
          expect(e.status).to eq(2)
        end
      end
    end
  end

  describe "#route_exists_by_gatewayid" do
    context "a route does exist to a gateway" do
      it "returns true" do
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables_with_gateway.get_json)
        expect(@textout).to receive(:puts).with('true')
        @command_route_table_json_vpcid.route_exists_by_gatewayid(externalid_route_table, cidr, gateway_id)
      end
    end
    context "a route does not exist to a gateway" do
      it "returns true" do
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables.get_json)
        expect(@textout).to receive(:puts).with('false')
        @command_route_table_json_vpcid.route_exists_by_gatewayid(externalid_route_table, cidr, gateway_id)
      end
    end
  end

  describe "#declare_route_to_gateway" do
    context "check flag specified and a route does exist to a gateway" do
      it "returns ok" do
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables_with_gateway.get_json)
        expect(@textout).to receive(:puts).with(ok_declare_route_to_gateway)
        begin
          @command_route_table_json_vpcid_check.declare_route_to_gateway(externalid_route_table, cidr, gateway_id)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end
    context "check flag specified and a route does not exist to a gateway" do
      it "returns critical" do
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables.get_json)
        expect(@textout).to receive(:puts).with(critical_declare_route_to_gateway)
        begin
          @command_route_table_json_vpcid_check.declare_route_to_gateway(externalid_route_table, cidr, gateway_id)
        rescue SystemExit => e
          expect(e.status).to eq(2)
        end
      end
    end
    context "route does exist to a gateway" do
      it "skip route creation" do
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables_with_gateway.get_json)
        expect(@textout).to receive(:puts).with(route_to_gateway_not_created)
        begin
          @command_route_table_json_vpcid.declare_route_to_gateway(externalid_route_table, cidr, gateway_id)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end
    context "route does not exist to a gateway" do
      it "create route" do
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables.get_json)
        expect(@shellout).to receive(:cli).with(create_route_to_gateway.aws.get_command, nil).and_return('{	"return" : "true" }')
        expect(@textout).to receive(:puts).with(route_to_gateway_created)
        begin
          @command_route_table_json_vpcid.declare_route_to_gateway(externalid_route_table, cidr, gateway_id)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end
    context "undo flag provided and route does exist to a gateway" do
      it "skip route creation" do
        expect(@undofile).to receive(:prepend).with("zaws route_table delete_route #{externalid_route_table} #{cidr} --region #{region} --vpcid #{vpc_id} $XTRA_OPTS", '#Delete route', 'undo.sh')
        expect(@shellout).to receive(:cli).with(describe_route_tables.aws.get_command, nil).and_return(single_route_tables_with_gateway.get_json)
        expect(@textout).to receive(:puts).with(route_to_gateway_not_created)
        begin
          @command_route_table_json_vpcid_undo.declare_route_to_gateway(externalid_route_table, cidr, gateway_id)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end
  end

end

