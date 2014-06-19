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

	  desc "id_subnet_by_ip","get subnet id by specifying ip address in subnet"
	  option :privateip, :type => :string, :desc => "ip addresses", :banner => "<privateip>", :aliases => :p, :required => true
	  option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>",  :aliases => :v, :required => true
	  def id_by_ip
        aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
	    aws.ec2.subnet.id_by_ip(options[:region],$stdout,(options[:verbose]?$stdout:nil),options[:vpcid],options[:privateip])
	  end

	  desc "id_subnet_by_cidrblock","get subnet id by specifying cidrblock for subnet"
	  option :cidrblock, :type => :string, :desc => "cidrblock", :banner => "<cidrblock>", :aliases => :c, :required => true
	  option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>",  :aliases => :v, :required => true
	  def id_by_cidrblock
        aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
		aws.ec2.subnet.id_by_cidrblock(options[:region],$stdout,(options[:verbose]?$stdout:nil),options[:vpcid],options[:cidrblock])
	  end

	  desc "exists","determine if a subnet exists."
	  option :cidrblock, :type => :string, :desc => "cidrblock", :banner => "<cidrblock>", :aliases => :c, :required => true
	  option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>",  :aliases => :v, :required => true
	  def exists 
        aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
		aws.ec2.subnet.exists(options[:region],$stdout,(options[:verbose]?$stdout:nil),options[:vpcid],options[:cidrblock])
	  end

	  desc "declare","create a subnet if it does not exist already"
	  option :cidrblock, :type => :string, :desc => "cidrblock", :banner => "<cidrblock>", :aliases => :c, :required => true
	  option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>",  :aliases => :v, :required => true
      option :availabilityzone, :type => :string, :desc => "AWS availability zone (eg us-west-1,us-west-2,...)", :banner => "<azone>",  :aliases => :a, :required => true
      option :availabilitytimeout, :type => :numeric, :desc => "AWS availability zone (eg us-west-1,us-west-2,...)", :banner => "<azone>",  :aliases => :t, :default => 30
      option :nagios, :type => :boolean, :desc => "Returns a nagios check result",  :aliases => :n, :default => false
      option :undofile, :type => :string, :desc => "File for undo commands", :banner => "<undofile>", :aliases => :f, :default => nil
	  def declare 
        aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
		exitcode=aws.ec2.subnet.declare(options[:region],options[:vpcid],options[:cidrblock],options[:availabilityzone],options[:availabilitytimeout],$stdout,(options[:verbose]?$stdout:nil),options[:nagios],options[:undofile])
		exit exitcode
	  end

	  desc "delete","delete a subnet if it exists already"
	  option :cidrblock, :type => :string, :desc => "cidrblock", :banner => "<cidrblock>", :aliases => :c, :required => true
	  option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>",  :aliases => :v, :required => true
	  def delete 
        aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
		aws.ec2.subnet.delete(options[:region],$stdout,(options[:verbose]?$stdout:nil),options[:vpcid],options[:cidrblock])
	  end


	end
  end
end
