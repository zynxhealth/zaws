require 'thor'

module ZAWS
  module Command
	class Load_Balancer < Thor 
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

	  desc "view","View load balancers."
	  option :viewtype, :type => :string, :desc => "View type, json or table", :banner => "<viewtype>", :aliases => :w, :default => "table"
	  def view
		@aws.elb.load_balancer.view(options[:region],options[:viewtype],@out,(options[:verbose]?@out:nil))
	  end

	  desc "exists LOAD_BALANCER_NAME","Determine if a load balancer exists by its LOAD_BALANCER_NAME"
	  def exists(lbname) 
		val,instances=@aws.elb.load_balancer.exists(options[:region],lbname,@out,(options[:verbose]?@out:nil))
		return val
	  end

	  desc "create_in_subnet LOAD_BALANCER_NAME LB_PROTOCOL LB_PORT IN_PROTOCOL IN_PORT SECURITY_GROUP","Create a new load balancer in the subnets specified by the option --cidrblocks."
	  option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>",  :aliases => :v, :default => nil
	  option :cidrblocks,:type => :array, :desc => "subnet cidr blocks to attach to load balancer, one per avaialability zone.", :banner => "<cidrblocks>", :aliases => :u
	  option :check, :type => :boolean, :desc => "Returns a check result",  :aliases => :n, :default => false
	  option :undofile, :type => :string, :desc => "File for undo commands", :banner => "<undofile>", :aliases => :f, :default => nil
	  def create_in_subnet(lbname,lbprotocol,lbport,inprotocol,inport,securitygroup)
		exitcode = @aws.elb.load_balancer.create_in_subnet(options[:region],lbname,lbprotocol,lbport,inprotocol,inport,securitygroup,options[:cidrblocks],options[:vpcid],options[:check],@out,(options[:verbose]?@out:nil),options[:undofile])
		exit exitcode
	  end

	  desc "delete LOAD_BALANCER_NAME","Delete load balancer identified by LOAD_BALANCER_NAME if it exists."
	  def delete(lbname) 
		@aws.elb.load_balancer.delete(options[:region],lbname,@out,(options[:verbose]?@out:nil))
	  end

	  desc "exists_instance LOAD_BALANCER_NAME INSTANCE_EXTERNAL_ID","Determine if an instance identified by the INSTANCE_EXTERNAL_ID is registered with load balancer identified by LOAD_BALANCER_NAME."
	  option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>",  :aliases => :v, :default => nil
	  def exists_instance(lbname,instance_external_id) 
		@out.puts "DEBUG: options[:region]=#{options[:region]}" if options[:verbose]
		@out.puts "DEBUG: lbname=#{lbname}" if options[:verbose]
		@out.puts "DEBUG: instance_external_id=#{instance_external_id}" if options[:verbose]
		@out.puts "DEBUG: options[:vpcid]=#{options[:vpcid]}" if options[:verbose]
		@aws.elb.load_balancer.exists_instance(options[:region],lbname,instance_external_id,options[:vpcid],@out,(options[:verbose]?@out:nil))
	  end

	  desc "register_instance LOAD_BALANCER_NAME INSTANCE_EXTERNAL_ID","Register an instance identified by the INSTANCE_EXTERNAL_ID is registered with load balancer identified by LOAD_BALANCER_NAME."
	  option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>",  :aliases => :v, :default => nil
      option :check, :type => :boolean, :desc => "Returns a check result",  :aliases => :n, :default => false
	  option :undofile, :type => :string, :desc => "File for undo commands", :banner => "<undofile>", :aliases => :f, :default => nil
	  def register_instance(lbname,instance_external_id) 
		@out.puts "DEBUG: options[:region]=#{options[:region]}" if options[:verbose]
		@out.puts "DEBUG: lbname=#{lbname}" if options[:verbose]
		@out.puts "DEBUG: instance_external_id=#{instance_external_id}" if options[:verbose]
		@out.puts "DEBUG: options[:vpcid]=#{options[:vpcid]}" if options[:verbose]
		@aws.elb.load_balancer.register_instance(options[:region],lbname,instance_external_id,options[:vpcid],options[:check],@out,(options[:verbose]?@out:nil),options[:undofile])
	  end

	  desc "deregister_instance LOAD_BALANCER_NAME INSTANCE_EXTERNAL_ID","Deregister an instance identified by the INSTANCE_EXTERNAL_ID is registered with load balancer identified by LOAD_BALANCER_NAME."
	  option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>",  :aliases => :v, :default => nil
	  def deregister_instance(lbname,instance_external_id) 
		@out.puts "DEBUG: options[:region]=#{options[:region]}" if options[:verbose]
		@out.puts "DEBUG: lbname=#{lbname}" if options[:verbose]
		@out.puts "DEBUG: instance_external_id=#{instance_external_id}" if options[:verbose]
		@out.puts "DEBUG: options[:vpcid]=#{options[:vpcid]}" if options[:verbose]
		@aws.elb.load_balancer.deregister_instance(options[:region],lbname,instance_external_id,options[:vpcid],@out,(options[:verbose]?@out:nil))
	  end

	  desc "exists_listener LOAD_BALANCER_NAME LBPROTOCOL LBPORT INPROTOCOL INPORT","Determine if a listener is registered with load balancer."
	  def exists_listener(lbname,lbprotocol,lbport,inprotocol,inport) 
		@out.puts "DEBUG: lbname=#{lbname}" if options[:verbose] 
        @out.puts "DEBUG: lbprotocol=#{lbprotocol}" if options[:verbose]
        @out.puts "DEBUG: lbport=#{lbport}" if options[:verbose]
        @out.puts "DEBUG: inprotocol=#{inprotocol}" if options[:verbose]
		@out.puts "DEBUG: inport=#{inport}" if options[:verbose]
		@aws.elb.load_balancer.exists_listener(options[:region],lbname,lbprotocol,lbport,inprotocol,inport,@out,(options[:verbose]?@out:nil))
	  end

	  desc "declare_listener LOAD_BALANCER_NAME LBPROTOCOL LBPORT INPROTOCOL INPORT","Create a new listener."
      option :check, :type => :boolean, :desc => "Returns a check result",  :aliases => :n, :default => false
	  option :undofile, :type => :string, :desc => "File for undo commands", :banner => "<undofile>", :aliases => :f, :default => nil
	  def declare_listener(lbname,lbprotocol,lbport,inprotocol,inport) 
		@out.puts "DEBUG: lbname=#{lbname}" if options[:verbose] 
        @out.puts "DEBUG: lbprotocol=#{lbprotocol}" if options[:verbose]
        @out.puts "DEBUG: lbport=#{lbport}" if options[:verbose]
        @out.puts "DEBUG: inprotocol=#{inprotocol}" if options[:verbose]
		@out.puts "DEBUG: inport=#{inport}" if options[:verbose]
		@aws.elb.load_balancer.declare_listener(options[:region],lbname,lbprotocol,lbport,inprotocol,inport,options[:check],@out,(options[:verbose]?@out:nil),options[:undofile])
	  end

	  desc "delete_listener LOAD_BALANCER_NAME LBPROTOCOL LBPORT INPROTOCOL INPORT","Delete listener."
	  def delete_listener(lbname,lbprotocol,lbport,inprotocol,inport) 
		@out.puts "DEBUG: lbname=#{lbname}" if options[:verbose] 
        @out.puts "DEBUG: lbprotocol=#{lbprotocol}" if options[:verbose]
        @out.puts "DEBUG: lbport=#{lbport}" if options[:verbose]
        @out.puts "DEBUG: inprotocol=#{inprotocol}" if options[:verbose]
		@out.puts "DEBUG: inport=#{inport}" if options[:verbose]
		@aws.elb.load_balancer.delete_listener(options[:region],lbname,lbprotocol,lbport,inprotocol,inport,@out,(options[:verbose]?@out:nil))
	  end

	end
  end
end

