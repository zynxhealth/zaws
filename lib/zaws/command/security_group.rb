require 'thor'

module ZAWS
  module Command
    class Security_Group < Thor
      class_option :region, :type => :string, :desc => "AWS Region", :banner => "<region>", :aliases => :r, :required => true
      class_option :verbose, :type => :boolean, :desc => "Verbose outout", :aliases => :d, :default => false

      desc "view", "View security groups."
      option :viewtype, :type => :string, :desc => "View type, json or table", :banner => "<viewtype>", :aliases => :w, :default => "table"
      option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>", :aliases => :v, :default => nil
      def view
        aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
        aws.ec2.security_group.view(options[:region], options[:viewtype], $stdout, (options[:verbose] ? $stdout : nil), options[:vpcid])
      end

      desc "exists_by_name GROUP_NAME", "Determine if a security group exists by name GROUP_NAME."
      option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>", :aliases => :v, :default => nil
      def exists_by_name(group_name)
        aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
        aws.ec2.security_group.exists(options[:region], $stdout, (options[:verbose] ? $stdout : nil), options[:vpcid], group_name)
      end

      desc "declare GROUP_NAME DESCRIPTION", "Declare a new security group GROUP_NAME, but skip creating it if it exists."
      option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>", :aliases => :v, :default => nil
      option :nagios, :type => :boolean, :desc => "Returns a nagios check result", :aliases => :n, :default => false
      option :undofile, :type => :string, :desc => "File for undo commands", :banner => "<undofile>", :aliases => :f, :default => nil
      def declare(group_name, description)
        aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
        exitcode = aws.ec2.security_group.declare(options[:region], options[:vpcid], group_name, description, options[:nagios], $stdout, (options[:verbose] ? $stdout : nil), options[:undofile])
        exit exitcode
      end

      desc "delete GROUP_NAME", "Delete a new security group GROUP_NAME, but skip it if it does not exist."
      option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>", :aliases => :v, :default => nil
      def delete(group_name)
        aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
        aws.ec2.security_group.delete(options[:region], $stdout, (options[:verbose] ? $stdout : nil), options[:vpcid], group_name)
      end

      desc "ingress_group_exists TARGET_GROUP_NAME SOURCE_GROUP_NAME PROTOCOL PORT", "Determine if an ingress security group rule exists."
      option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>", :aliases => :v, :default => nil
      def ingress_group_exists(target, source, protocol, port)
        aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
        aws.ec2.security_group.ingress_group_exists(options[:region], options[:vpcid], target, source, protocol, port, $stdout, (options[:verbose] ? $stdout : nil))
      end

      desc "ingress_cidr_exists TARGET_GROUP_NAME CIDR PROTOCOL PORT", "Determine if an ingress CIDR rule exists."
      option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>", :aliases => :v, :default => nil
      def ingress_cidr_exists(target, cidr, protocol, port)
        aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
        aws.ec2.security_group.ingress_cidr_exists(options[:region], options[:vpcid], target, cidr, protocol, port, $stdout, (options[:verbose] ? $stdout : nil))
      end

      desc "declare_ingress_group TARGET_GROUP_NAME SOURCE_GROUP_NAME PROTOCOL PORT", "Declare an ingress security group rule."
      option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>", :aliases => :v, :default => nil
      option :nagios, :type => :boolean, :desc => "Returns a nagios check result", :aliases => :n, :default => false
      option :undofile, :type => :string, :desc => "File for undo commands", :banner => "<undofile>", :aliases => :f, :default => nil
      def declare_ingress_group(target, source, protocol, port)
        aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
        exitcode = aws.ec2.security_group.declare_ingress_group(options[:region], options[:vpcid], target, source, protocol, port, options[:nagios], $stdout, (options[:verbose] ? $stdout : nil), options[:undofile])
        exit exitcode
      end

      desc "declare_ingress_cidr TARGET_GROUP_NAME CIDR PROTOCOL PORT", "Declare an ingress CIDR rule."
      option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>", :aliases => :v, :default => nil
      option :nagios, :type => :boolean, :desc => "Returns a nagios check result", :aliases => :n, :default => false
      option :undofile, :type => :string, :desc => "File for undo commands", :banner => "<undofile>", :aliases => :f, :default => nil
      def declare_ingress_cidr(target, cidr, protocol, port)
        aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
        exitcode = aws.ec2.security_group.declare_ingress_cidr(options[:region], options[:vpcid], target, cidr, protocol, port, options[:nagios], $stdout, (options[:verbose] ? $stdout : nil), options[:undofile])
        exit exitcode
      end

      desc "delete_ingress_group TARGET_GROUP_NAME SOURCE_GROUP_NAME PROTOCOL PORT", "Delete an ingress security group rule."
      option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>", :aliases => :v, :default => nil
      def delete_ingress_group(target, source, protocol, port)
        aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
        aws.ec2.security_group.delete_ingress_group(options[:region], options[:vpcid], target, source, protocol, port, $stdout, (options[:verbose] ? $stdout : nil))
      end

      desc "delete_ingress_cidr TARGET_GROUP_NAME CIDR PROTOCOL PORT", "Delete an ingress security cidr rule."
      option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>", :aliases => :v, :default => nil
      def delete_ingress_cidr(target, cidr, protocol, port)
        aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
        aws.ec2.security_group.delete_ingress_cidr(options[:region], options[:vpcid], target, cidr, protocol, port, $stdout, (options[:verbose] ? $stdout : nil))
      end

    end
  end
end

	
