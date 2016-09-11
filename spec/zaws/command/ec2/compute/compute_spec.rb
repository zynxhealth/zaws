require 'spec_helper'

describe ZAWS::Services::EC2::Compute do

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
                          :vpcid=> @var_vpc_id
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
end


