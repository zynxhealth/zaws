require 'spec_helper'

describe ZAWS::Services::EC2::RouteTable do

  let(:route_table_created) { ZAWS::Helper::Output.colorize("Route table created with external id: my_route_table.", AWS_consts::COLOR_YELLOW) }
  let(:route_table_exist) { ZAWS::Helper::Output.colorize("Route table exists already. Skipping Creation.", AWS_consts::COLOR_GREEN) }
  let(:route_table_not_deleted) { ZAWS::Helper::Output.colorize("Route table does not exist. Skipping deletion.", AWS_consts::COLOR_GREEN) }
  let(:route_table_deleted) { ZAWS::Helper::Output.colorize("Route table deleted.", AWS_consts::COLOR_YELLOW) }
  let(:route_table_ok) { ZAWS::Helper::Output.colorize("OK: Route table exists.", AWS_consts::COLOR_GREEN) }
  let(:route_table_critical) { ZAWS::Helper::Output.colorize("CRITICAL: Route table does not exist.", AWS_consts::COLOR_RED) }

  let(:ok_route_propagation) { ZAWS::Helper::Output.colorize("OK: Route propagation from gateway enabled.", AWS_consts::COLOR_GREEN) }
  let(:critical_route_propagation) { ZAWS::Helper::Output.colorize("CRITICAL: Route propagation from gateway not enabled.", AWS_consts::COLOR_RED) }

  let(:ok_declare_route) { ZAWS::Helper::Output.colorize("OK: Route to instance exists.", AWS_consts::COLOR_GREEN) }
  let(:critical_declare_route) { ZAWS::Helper::Output.colorize("CRITICAL: Route to instance does not exist.", AWS_consts::COLOR_RED) }

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
  let (:external_id) { "my_instance" }
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
    instances.instance_id(0, instance_id).tags(0, tags)
  }

  let(:empty_route_tables) {
    ZAWS::External::AWSCLI::Generators::Result::EC2::RouteTables.new
  }

  let(:single_route_tables) {
    single_route_table=ZAWS::External::AWSCLI::Generators::Result::EC2::RouteTables.new
    single_route_table.vpc_id(0, vpc_id).route_table_id(0, route_table_id)
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
    create_tags.resource("rtb-XXXXXXX").tags(tags)
    create_tags.aws.region(region)
    create_tags
  }

  let(:single_subnets) {
    subnets = ZAWS::External::AWSCLI::Generators::Result::EC2::Subnets.new
    subnets.subnet_id(0, "subnet-YYYYYY")
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

  describe "#declare_propagation_from_gateway" do
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


  describe "#declare_route" do
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

end

