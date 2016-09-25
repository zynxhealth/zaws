require 'thor'

module ZAWS
  module Command
    class Vpc < Thor
      class_option :region, :type => :string, :desc => "AWS Region", :banner => "<region>", :aliases => :r, :required => true, :default => "us-east-1"
      class_option :verbose, :type => :boolean, :desc => "Verbose outout", :aliases => :d, :default => false

      attr_accessor :aws
      attr_accessor :out
      attr_accessor :print_exit_code

      def initialize(*args)
        super
        shellout=ZAWS::Helper::Shell.new
        awscli = ZAWS::AWSCLI.new(shellout,false)
        @aws = ZAWS::AWS.new(shellout, awscli)
        @out = $stdout
        @print_exit_code = false
      end

      desc "view", "View compute instances."
      option :viewtype, :type => :string, :desc => "View type, json or table", :banner => "<viewtype>", :aliases => :w, :default => "table"
      def view
        @aws.ec2.vpc.view(options[:region], options[:viewtype], @out, (options[:verbose] ? @out : nil))
      end

      desc "check_management_data", "View data used to manage the vpc."
      option :profile, :type => :string, :desc => "AWS profile to use.", :banner => "<profile>", :aliases => :w, :default => nil
      def check_management_data
        @aws.ec2.vpc.check_management_data(options[:region],  @out, (options[:verbose] ? @out : nil), options[:profile])
      end

      desc "declare CIDR EXTERNALID", "Declare a new vpc with a name and CIDR."
      option :availabilitytimeout, :type => :numeric, :desc => "Timeout before exiting from waiting for state to change from pending to available.", :banner => "<azone>", :aliases => :t, :default => 30
      option :profile, :type => :string, :desc => "AWS profile to use.", :banner => "<profile>", :aliases => :w, :default => nil
      def declare(cidr,externalid)
        exitcode= @aws.ec2.vpc.declare(options[:region],cidr, externalid,options[:availabilitytimeout], @out, (options[:verbose] ? @out : nil), options[:profile])
        exit exitcode unless @print_exit_code
		    @out.puts(exitcode)
      end

      desc "view_peering", "View peering connections between vpcs."
      option :viewtype, :type => :string, :desc => "View type, json or table", :banner => "<viewtype>", :aliases => :w, :default => "table"
      def view_peering
        @aws.ec2.vpc.view_peering(options[:region], options[:viewtype], @out, (options[:verbose] ? @out : nil))
      end

    end
  end
end

	
