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
                    :viewtype => 'json',
                    :owner => 'me'
    }

    options_table = {:region => @var_region,
                     :verbose => false,
                     :check => false,
                     :undofile => false,
                     :viewtype => 'table',
                    :owner => 'self'
    }


    @textout=double('outout')
    @shellout=double('ZAWS::Helper::Shell')
    @undofile=double('ZAWS::Helper::ZFile')
    @aws=ZAWS::AWS.new(@shellout, ZAWS::AWSCLI.new(@shellout, true), @undofile)
    @command_image = ZAWS::Command::Compute.new([], options_table, {})
    @command_image.aws=@aws
    @command_image.out=@textout
    @command_image.print_exit_code = true
    @command_image_json = ZAWS::Command::Compute.new([], options_json, {})
    @command_image_json.aws=@aws
    @command_image_json.out=@textout
    @command_image_json.print_exit_code = true

  }

  describe "#view" do

    it "Get compute images in a human readable table." do
      desc_image = ZAWS::External::AWSCLI::Commands::EC2::DescribeImages.new
      desc_image.owner("self")
      desc_image.aws.output(@var_output_table).region(@var_region)
      expect(@shellout).to receive(:cli).with(desc_image.aws.get_command, nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @command_image.view_images
    end

    it "Get compute images in JSON form for me specifically" do
      desc_image = ZAWS::External::AWSCLI::Commands::EC2::DescribeImages.new
      desc_image.owner("me")
      desc_image.aws.output(@var_output_json).region(@var_region)
      expect(@shellout).to receive(:cli).with(desc_image.aws.get_command, nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @command_image_json.view_images
    end

  end
end


