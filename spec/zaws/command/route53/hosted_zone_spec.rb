require 'spec_helper'

describe ZAWS::Services::Route53::HostedZone do
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
    @command_hosted_zone = ZAWS::Command::Hosted_Zone.new([], options_table, {})
    @command_hosted_zone.aws=@aws
    @command_hosted_zone.out=@textout
    @command_hosted_zone.print_exit_code = true
    @command_hosted_zone_json = ZAWS::Command::Hosted_Zone.new([], options_json, {})
    @command_hosted_zone_json.aws=@aws
    @command_hosted_zone_json.out=@textout
    @command_hosted_zone_json.print_exit_code = true

  }

  describe "#view" do
    it "Get hosted zone in a human readable table. " do
      list_hosted_zones= ZAWS::External::AWSCLI::Commands::Route53::ListHostedZones.new
      list_hosted_zones.aws.output(@var_output_table)
      expect(@shellout).to receive(:cli).with(list_hosted_zones.aws.get_command, nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @command_hosted_zone.view()
    end

    it "Get hosted zone in JSON form " do
      list_hosted_zones= ZAWS::External::AWSCLI::Commands::Route53::ListHostedZones.new
      list_hosted_zones.aws.output(@var_output_json)
      expect(@shellout).to receive(:cli).with(list_hosted_zones.aws.get_command, nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @command_hosted_zone_json.view()
    end
  end

end


