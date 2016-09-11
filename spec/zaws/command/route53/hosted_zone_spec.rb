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


  describe "#view_records" do
    it "Get records for hosted zone in a human readable table. " do
      hosted_zones=ZAWS::External::AWSCLI::Generators::Result::Route53::HostedZones.new
      hosted_zones.name(0,"abc.com.").id(0,"id-???")

      list_hosted_zones= ZAWS::External::AWSCLI::Commands::Route53::ListHostedZones.new
      list_hosted_zones.aws.output(@var_output_json)
      expect(@shellout).to receive(:cli).with(list_hosted_zones.aws.get_command, nil).ordered.and_return(hosted_zones.get_json)

      list_resource_record_sets= ZAWS::External::AWSCLI::Commands::Route53::ListResourceRecordSets.new
      list_resource_record_sets.hosted_zone_id("id-???")
      list_resource_record_sets.aws.output(@var_output_table)
      expect(@shellout).to receive(:cli).with(list_resource_record_sets.aws.get_command, nil).ordered.and_return('test output')

      expect(@textout).to receive(:puts).with('test output').ordered
      @command_hosted_zone.view_records("abc.com.")
    end

    it "Get records for hosted zone in a JSON form. " do
      hosted_zones=ZAWS::External::AWSCLI::Generators::Result::Route53::HostedZones.new
      hosted_zones.name(0,"abc.com.").id(0,"id-???")

      list_hosted_zones= ZAWS::External::AWSCLI::Commands::Route53::ListHostedZones.new
      list_hosted_zones.aws.output(@var_output_json)
      expect(@shellout).to receive(:cli).with(list_hosted_zones.aws.get_command, nil).ordered.and_return(hosted_zones.get_json)

      list_resource_record_sets= ZAWS::External::AWSCLI::Commands::Route53::ListResourceRecordSets.new
      list_resource_record_sets.hosted_zone_id("id-???")
      list_resource_record_sets.aws.output(@var_output_json)
      expect(@shellout).to receive(:cli).with(list_resource_record_sets.aws.get_command, nil).ordered.and_return('test output')

      expect(@textout).to receive(:puts).with('test output').ordered
      @command_hosted_zone_json.view_records("abc.com.")
    end
  end

end


