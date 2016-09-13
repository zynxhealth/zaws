require 'spec_helper'

describe ZAWS::Services::EC2::RouteTable do

  let(:empty_route_table){

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
      filter=ZAWS::External::AWSCLI::Commands::EC2::Filter.new
      desc_route_tbls = ZAWS::External::AWSCLI::Commands::EC2::DescribeRouteTables.new
      aws_command = ZAWS::External::AWSCLI::Commands::AWS.new
      desc_route_tbls = desc_route_tbls.filter(filter.vpc_id(@var_vpc_id))
      aws_command = aws_command.output(@var_output_json).region(@var_region).subcommand(desc_route_tbls)
      expect(@shellout).to receive(:cli).with(aws_command.get_command, nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @command_route_table_json_vpcid.view
    end

  end

  describe "#exists_by_external_id" do
    context "route table does not exist" do
      it "Determine a route table DOES NOT exists by external id" do

      end

    end
  end

end

