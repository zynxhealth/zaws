require 'spec_helper'

describe ZAWS::Services::EC2::Elasticip do

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
end


