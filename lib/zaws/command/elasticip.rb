require 'thor'

module ZAWS
  module Command
	class Elasticip < Thor 
	  class_option :region, :type => :string, :desc => "AWS Region", :banner => "<region>",  :aliases => :r, :required => true
	  class_option :verbose, :type => :boolean, :desc => "Verbose outout", :aliases => :d, :default => false

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


	  desc "view","View elastic ips."
	  option :viewtype, :type => :string, :desc => "View type, json or table", :banner => "<viewtype>", :aliases => :w, :default => "table"
	  option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>",  :aliases => :v, :default => nil
	  def view
		@aws.ec2.elasticip.view(options[:region],options[:viewtype],@out,(options[:verbose]?@out:nil),options[:vpcid])
	  end

	  desc "assoc_exists EXTERNAL_ID","Determine by an instance's EXTERNAL_ID if it has an elastic."
	  option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>",  :aliases => :v, :default => nil
	  def assoc_exists(externalid) 
		val,instanceid,assoc,alloc,ip=@aws.ec2.elasticip.assoc_exists(options[:region],externalid,@out,(options[:verbose]?@out:nil),options[:vpcid])
		return val
	  end

	  desc "declare EXTERNAL_ID","Declare an instance by its instance's EXTERNAL_ID  should have an elastic ip."
	  option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>",  :aliases => :v, :default => nil
      option :check, :type => :boolean, :desc => "Returns a nagios check result",  :aliases => :n, :default => false
	  option :undofile, :type => :string, :desc => "File for undo commands", :banner => "<undofile>", :aliases => :f, :default => nil
	  def declare(externalid) 
		val=@aws.ec2.elasticip.declare(options[:region],externalid,@out,(options[:verbose]?@out:nil),options[:vpcid],options[:check],options[:undofile])
		return val
	  end

	  desc "release EXTERNAL_ID","Release an elastic ip address a specific instance. The instance's EXTERNAL_ID is required."
	  option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>",  :aliases => :v, :default => nil
	  def release(externalid) 
		val=@aws.ec2.elasticip.release(options[:region],externalid,@out,(options[:verbose]?@out:nil),options[:vpcid])
		return val
	  end

	end
  end
end

	
