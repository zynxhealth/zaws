require 'thor'

module ZAWS
  module Command
    class Route_Table < Thor
      class_option :region, :type => :string, :desc => "AWS Region", :banner => "<region>", :aliases => :r, :required => true
      class_option :verbose, :type => :boolean, :desc => "Verbose outout", :aliases => :d, :default => false

      attr_accessor :aws
      attr_accessor :out
      attr_accessor :print_exit_code

      def initialize(*args)
        super
        shellout=ZAWS::Helper::Shell.new
        awscli = ZAWS::AWSCLI.new(shellout)
        @aws = ZAWS::AWS.new(shellout, awscli)
        @out = $stdout
        @print_exit_code = false
      end

      desc "view", "View route tables."
      option :viewtype, :type => :string, :desc => "View type, json or table", :banner => "<viewtype>", :aliases => :w, :default => "table"
      option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>", :aliases => :v, :default => nil

      def view
        @out.puts(@aws.ec2.route_table.view(options[:region], options[:viewtype], @out, (options[:verbose] ? @out : nil), options[:vpcid]))
      end

      desc "exists_by_external_id EXTERNAL_ID", "Determine if a route table exists by EXTERNAL_ID."
      option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>", :aliases => :v, :default => nil

      def exists_by_external_id(externalid)
        @aws.ec2.route_table.exists(options[:region], @out, (options[:verbose] ? @out : nil), options[:vpcid], externalid)
      end

      desc "declare EXTERNAL_ID VPCID", "Declare a new route table by EXTERNAL_ID in VPCID, but skip creating it if it exists."
      option :nagios, :type => :boolean, :desc => "Returns a nagios check result", :aliases => :n, :default => false
      option :undofile, :type => :string, :desc => "File for undo commands", :banner => "<undofile>", :aliases => :f, :default => nil

      def declare(externalid, vpcid)
        exitcode = @aws.ec2.route_table.declare(options[:region], vpcid, externalid, options[:nagios], @out, (options[:verbose] ? @out : nil), options[:undofile])
        exit exitcode
      end

      desc "delete EXTERNAL_ID", "Delete route table by its EXTERNAL_ID."
      option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>", :aliases => :v, :default => nil

      def delete(externalid)
        @aws.ec2.route_table.delete(options[:region], @out, (options[:verbose] ? @out : nil), options[:vpcid], externalid)
      end

      desc "route_exists_by_instance ROUTE_TABLE CIDR_BLOCK INSTANCE_EXTERNAL_ID", "Determine if a route exists for CIDR_BLOCK in ROUTE_TABLE to an instance INSTANCE_EXTERNAL_ID."
      option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>", :aliases => :v, :default => nil

      def route_exists_by_instance(routetable, cidrblock, externalid)
        @aws.ec2.route_table.route_exists_by_instance(options[:region], @out, (options[:verbose] ? @out : nil), options[:vpcid], routetable, cidrblock, externalid)
      end

      desc "declare_route ROUTE_TABLE CIDR_BLOCK INSTANCE_EXTERNAL_ID", "Declare a new route to instance INSTANCE_EXTERNAL_ID for CIDR_BLOCK in ROUTE_TABLE, but skip creating it if it exists."
      option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>", :aliases => :v, :default => nil
      option :nagios, :type => :boolean, :desc => "Returns a nagios check result", :aliases => :n, :default => false
      option :undofile, :type => :string, :desc => "File for undo commands", :banner => "<undofile>", :aliases => :f, :default => nil

      def declare_route(routetable, cidrblock, externalid)
        exitcode = @aws.ec2.route_table.declare_route(options[:region], @out, (options[:verbose] ? @out : nil), options[:vpcid], routetable, cidrblock, externalid, options[:nagios], options[:undofile])
        exit exitcode
      end

      desc "delete_route ROUTE_TABLE CIDR_BLOCK", "Delete a route to CIDR_BLOCK in ROUTE_TABLE, but skip deletion if it doesn't exist."
      option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>", :aliases => :v, :default => nil

      def delete_route(routetable, cidrblock)
        @aws.ec2.route_table.delete_route(options[:region], @out, (options[:verbose] ? @out : nil), options[:vpcid], routetable, cidrblock)
      end

      desc "route_exists_by_gatewayid ROUTE_TABLE CIDR_BLOCK GATEWAY_ID", "Determine if a route exists for CIDR_BLOCK in ROUTE_TABLE to GATEWAY_ID."
      option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>", :aliases => :v, :default => nil

      def route_exists_by_gatewayid(routetable, cidrblock, gatewayid)
        @aws.ec2.route_table.route_exists_by_gatewayid(options[:region], @out, (options[:verbose] ? @out : nil), options[:vpcid], routetable, cidrblock, gatewayid)
      end

      desc "declare_route_to_gateway ROUTE_TABLE CIDR_BLOCK GATEWAY_ID", "Declare a new route to GATEWAY_ID, but skip creating it if it exists."
      option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>", :aliases => :v, :default => nil
      option :nagios, :type => :boolean, :desc => "Returns a nagios check result", :aliases => :n, :default => false
      option :undofile, :type => :string, :desc => "File for undo commands", :banner => "<undofile>", :aliases => :f, :default => nil

      def declare_route_to_gateway(routetable, cidrblock, gatewayid)
        exitcode = @aws.ec2.route_table.declare_route_to_gateway(options[:region], @out, (options[:verbose] ? @out : nil), options[:vpcid], routetable, cidrblock, gatewayid, options[:nagios], options[:undofile])
        exit exitcode
      end

      desc "subnet_assoc_exists ROUTE_TABLE_EXTERNAL_ID CIDRBLOCK", "Determine if a route table is associated to a subnet."
      option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>", :aliases => :v, :default => nil

      def subnet_assoc_exists(rtable_externalid, cidrblock)
        @aws.ec2.route_table.subnet_assoc_exists(options[:region], @out, (options[:verbose] ? @out : nil), options[:vpcid], rtable_externalid, cidrblock)
      end

      desc "assoc_subnet ROUTE_TABLE_EXTERNAL_ID CIDRBLOCK", "Associate a route table to a subnet."
      option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>", :aliases => :v, :default => nil
      option :nagios, :type => :boolean, :desc => "Returns a nagios check result", :aliases => :n, :default => false
      option :undofile, :type => :string, :desc => "File for undo commands", :banner => "<undofile>", :aliases => :f, :default => nil

      def assoc_subnet(rtable_externalid, cidrblock)
        exitcode = @aws.ec2.route_table.assoc_subnet(options[:region], @out, (options[:verbose] ? @out : nil), options[:vpcid], rtable_externalid, cidrblock, options[:nagios], options[:undofile])
        exit exitcode
      end

      desc "delete_assoc_subnet ROUTE_TABLE_EXTERNAL_ID CIDRBLOCK", "Delete association of route table to subnet."
      option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>", :aliases => :v, :default => nil

      def delete_assoc_subnet(rtable_externalid, cidrblock)
        @aws.ec2.route_table.delete_assoc_subnet(options[:region], @out, (options[:verbose] ? @out : nil), options[:vpcid], rtable_externalid, cidrblock)
      end

      desc "propagation_exists_from_gateway ROUTE_TABLE_EXTERNAL_ID VIRTUAL_GATEWAY_ID", "Determine if route propagation from a gateway exists."
      option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>", :aliases => :v, :default => nil

      def propagation_exists_from_gateway(rtable_externalid, vgatewayid)
        @aws.ec2.route_table.propagation_exists_from_gateway(options[:region], @out, (options[:verbose] ? @out : nil), options[:vpcid], rtable_externalid, vgatewayid)
      end

      desc "declare_propagation_from_gateway ROUTE_TABLE_EXTERNAL_ID VIRTUAL_GATEWAY_ID", "Propagate routes to the routing tables from a virtual gateway."
      option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>", :aliases => :v, :default => nil
      option :nagios, :type => :boolean, :desc => "Returns a nagios check result", :aliases => :n, :default => false
      option :undofile, :type => :string, :desc => "File for undo commands", :banner => "<undofile>", :aliases => :f, :default => nil

      def declare_propagation_from_gateway(rtable_externalid, vgatewayid)
        exitcode = @aws.ec2.route_table.declare_propagation_from_gateway(options[:region], @out, (options[:verbose] ? @out : nil), options[:vpcid], rtable_externalid, vgatewayid, options[:nagios], options[:undofile])
        exit exitcode
      end

      desc "delete_propagation_from_gateway ROUTE_TABLE_EXTERNAL_ID GATEWAY_ID", "Delete route propagation from virtual gateway."
      option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>", :aliases => :v, :default => nil

      def delete_propagation_from_gateway(rtable_externalid, vgatewayid)
        @aws.ec2.route_table.delete_propagation_from_gateway(options[:region], @out, (options[:verbose] ? @out : nil), options[:vpcid], rtable_externalid, vgatewayid)
      end

    end
  end
end

	
