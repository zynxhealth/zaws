require 'spec_helper'

describe ZAWS::Services::S3::Bucket do
  before(:each) {

    @var_security_group_id="sg-abcd1234"
    @var_output_json="json"
    @var_output_table="table"
    @var_region="us-west-1"
    @var_vpc_id="my_vpc_id"
    @var_sec_group_name="my_security_group_name"


    options_table = {:region => @var_region,
                     :verbose => false,
                     :check => false,
                     :undofile => false,
                     :viewtype => 'table',
                    :dest => '/tmp/dir'
    }


    @textout=double('outout')
    @shellout=double('ZAWS::Helper::Shell')
    @undofile=double('ZAWS::Helper::ZFile')
    @aws=ZAWS::AWS.new(@shellout, ZAWS::AWSCLI.new(@shellout, true), @undofile)
    @command_bucket = ZAWS::Command::Bucket.new([], options_table, {})
    @command_bucket.aws=@aws
    @command_bucket.out=@textout
    @command_bucket.print_exit_code = true

  }

  describe "#declare" do
    it "Declare an S3 bucket by name but skip its creation because it already exists." do
      ls= ZAWS::External::AWSCLI::Commands::S3::Ls.new
      ls.aws.region(@var_region)
      expect(@shellout).to receive(:cli).with(ls.aws.get_command).ordered.and_return("2014-08-25 15:49:19 test-bucket")
      @command_bucket.declare("test-bucket")
    end

    it "Declare an S3 bucket so that it's created when it doesn't exist" do
      ls= ZAWS::External::AWSCLI::Commands::S3::Ls.new
      ls.aws.region(@var_region)
      expect(@shellout).to receive(:cli).with(ls.aws.get_command).ordered.and_return("2014-08-25 15:49:19 some-other-bucket")

      mb= ZAWS::External::AWSCLI::Commands::S3::Mb.new
      mb.bucket_name("test-bucket")
      mb.aws.region(@var_region)
      expect(@shellout).to receive(:cli).with(mb.aws.get_command,@textout).ordered.and_return("make_bucket: s3://test-bucket")

      @command_bucket.declare("test-bucket")
    end
  end


  describe "#sync" do
    it "Sync the entire contents of an s3 bucket to the specified directory" do
      sync= ZAWS::External::AWSCLI::Commands::S3::Sync.new
      sync.source_name("s3://test-bucket").target_name("/tmp/dir")
      sync.aws.region(@var_region)
      expect(@shellout).to receive(:cli).with(sync.aws.get_command,nil).ordered.and_return("S3Output")
      @command_bucket.sync("s3://test-bucket")

    end
  end

end


