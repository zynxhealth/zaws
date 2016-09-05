require 'thor'

module ZAWS
  module Command
  class Bucket < Thor
    class_option :region, :type => :string, :desc => "AWS Region", :banner => "<region>",  :aliases => :r, :required => true

	attr_accessor :aws
	attr_accessor :out
	attr_accessor :print_exit_code

	def initialize(*args)
	  super
	  shellout=ZAWS::Helper::Shell.new
	  awscli = ZAWS::AWSCLI.new(shellout)
	  @aws = ZAWS::AWS.new(shellout,awscli)
	  @out = $stdout
	  @print_exit_code = false
	end

    desc "declare BUCKET_NAME", "declare an S3 bucket."
    def declare(name)
      @aws.s3.bucket.declare(name,options[:region],@out)
    end

    desc "sync BUCKET_NAME[/PATH]", "download the contents of an S3 bucket."
    option :dest, :type => :string, :desc => "directory to save to.", :aliases => :d
    def sync(bucket_name)
      @aws.s3.bucket.sync(options[:region], bucket_name, options[:dest])
    end
  end
  end
end
