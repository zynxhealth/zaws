require 'thor'

module ZAWS
  module Command
	class Elasticip < Thor 
	  class_option :region, :type => :string, :desc => "AWS Region", :banner => "<region>",  :aliases => :r, :required => true
	  class_option :verbose, :type => :boolean, :desc => "Verbose outout", :aliases => :d, :default => false

	  desc "view","View elastic ips."
	  option :viewtype, :type => :string, :desc => "View type, json or table", :banner => "<viewtype>", :aliases => :w, :default => "table"
	  option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>",  :aliases => :v, :default => nil
	  def view
		aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
		aws.ec2.elasticip.view(options[:region],options[:viewtype],$stdout,(options[:verbose]?$stdout:nil),options[:vpcid])
	  end

	  desc "assoc_exists EXTERNAL_ID","Determine if an instance has an elastic ip associated."
	  option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>",  :aliases => :v, :default => nil
	  def assoc_exists(externalid) 
		aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
		val,instanceid,assoc,alloc,ip=aws.ec2.elasticip.assoc_exists(options[:region],externalid,$stdout,(options[:verbose]?$stdout:nil),options[:vpcid])
		return val
	  end

	  desc "declare EXTERNAL_ID","Declare that an instance should have an elastic ip."
	  option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>",  :aliases => :v, :default => nil
      option :nagios, :type => :boolean, :desc => "Returns a nagios check result",  :aliases => :n, :default => false
	  option :undofile, :type => :string, :desc => "File for undo commands", :banner => "<undofile>", :aliases => :f, :default => nil
	  def declare(externalid) 
		aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
		val=aws.ec2.elasticip.declare(options[:region],externalid,$stdout,(options[:verbose]?$stdout:nil),options[:vpcid],options[:nagios],options[:undofile])
		return val
	  end

	  desc "release EXTERNAL_ID","Delete elastic ip address from instance."
	  option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>",  :aliases => :v, :default => nil
	  def release(externalid) 
		aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
		val=aws.ec2.elasticip.release(options[:region],externalid,$stdout,(options[:verbose]?$stdout:nil),options[:vpcid])
		return val
	  end

	end
  end
end

	
