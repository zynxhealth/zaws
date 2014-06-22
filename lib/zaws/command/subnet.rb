require 'thor'

module ZAWS
  module Command
	class Subnet < Thor 
	  class_option :region, :type => :string, :desc => "AWS Region", :banner => "<region>",  :aliases => :r, :required => true
	  class_option :verbose, :type => :boolean, :desc => "Verbose outout", :aliases => :d, :default => false

	  desc "view","View subnets."
	  option :viewtype, :type => :string, :desc => "View type, json or table", :banner => "<viewtype>", :aliases => :w, :default => "table"
	  option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>",  :aliases => :v, :default => nil
	  def view
		aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
		aws.ec2.subnet.view(options[:region],options[:viewtype],$stdout,(options[:verbose]?$stdout:nil),options[:vpcid])
	  end

	  desc "id_by_ip PRIVATE_IP VPCID","get subnet id by specifying PRIVATE_IP address in subnet"
	  def id_by_ip(privateip,vpcid)
        aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
	    aws.ec2.subnet.id_by_ip(options[:region],$stdout,(options[:verbose]?$stdout:nil),vpcid,privateip)
	  end

	  desc "id_by_cidrblock CIDRBLOCK VPCID","get subnet id by specifying CIDRBLOCK for subnet"
	  def id_by_cidrblock(cidrblock,vpcid)
        aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
		aws.ec2.subnet.id_by_cidrblock(options[:region],$stdout,(options[:verbose]?$stdout:nil),vpcid,cidrblock)
	  end

	  desc "exists CIDRBLOCK VPCID","Determine if a subnet exists by CIDRBLOCK."
	  def exists(cidrblock,vpcid) 
        aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
		aws.ec2.subnet.exists(options[:region],$stdout,(options[:verbose]?$stdout:nil),vpcid,cidrblock)
	  end

	  desc "declare CIDRBLOCK AVAILABILITY_ZONE VPCID","Create a subnet if it does not exist already"
      option :availabilitytimeout, :type => :numeric, :desc => "AWS availability zone (eg us-west-1,us-west-2,...)", :banner => "<azone>",  :aliases => :t, :default => 30
      option :nagios, :type => :boolean, :desc => "Returns a nagios check result",  :aliases => :n, :default => false
      option :undofile, :type => :string, :desc => "File for undo commands", :banner => "<undofile>", :aliases => :f, :default => nil
	  def declare(cidrblock,availabilityzone,vpcid)
        aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
		exitcode=aws.ec2.subnet.declare(options[:region],vpcid,cidrblock,availabilityzone,options[:availabilitytimeout],$stdout,(options[:verbose]?$stdout:nil),options[:nagios],options[:undofile])
		exit exitcode
	  end

	  desc "delete CIDRBLOCK VPCID","Delete a subnet if it exists."
	  def delete(cidrblock,vpcid)
        aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
		aws.ec2.subnet.delete(options[:region],$stdout,(options[:verbose]?$stdout:nil),vpcid,cidrblock)
	  end
	
	end
  end
end
