require 'thor'

module ZAWS
  module Command
    class Subnet < Thor
      class_option :region, :type => :string, :desc => "AWS Region", :banner => "<region>", :aliases => :r, :required => true
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

      desc "view", "View subnets."
      option :viewtype, :type => :string, :desc => "View type, json or table", :banner => "<viewtype>", :aliases => :w, :default => "table"
      option :vpcid, :type => :string, :desc => "AWS VPC id", :banner => "<vpcid>", :aliases => :v, :default => nil

      def view
        @aws.ec2.subnet.view(options[:region], options[:viewtype], @out, (options[:verbose] ? @out : nil), options[:vpcid])
      end

      desc "id_by_ip PRIVATE_IP VPCID", "get subnet id by specifying PRIVATE_IP address in subnet"

      def id_by_ip(privateip, vpcid)
        @aws.ec2.subnet.id_by_ip(options[:region], @out, (options[:verbose] ? @out : nil), vpcid, privateip)
      end

      desc "id_by_cidrblock CIDRBLOCK VPCID", "get subnet id by specifying CIDRBLOCK for subnet"

      def id_by_cidrblock(cidrblock, vpcid)
        @aws.ec2.subnet.id_by_cidrblock(options[:region], @out, (options[:verbose] ? @out : nil), vpcid, cidrblock)
      end

      desc "exists CIDRBLOCK VPCID", "Determine if a subnet exists by CIDRBLOCK."

      def exists(cidrblock, vpcid)
        @aws.ec2.subnet.exists(options[:region], @out, (options[:verbose] ? @out : nil), vpcid, cidrblock)
      end

      desc "declare CIDRBLOCK AVAILABILITY_ZONE VPCID", "Create a subnet if it does not exist already"
      option :availabilitytimeout, :type => :numeric, :desc => "Timeout before exiting from waiting for state to change from pending to available.", :banner => "<azone>", :aliases => :t, :default => 30
      option :check, :type => :boolean, :desc => "Returns a check result", :aliases => :n, :default => false
      option :undofile, :type => :string, :desc => "File for undo commands", :banner => "<undofile>", :aliases => :f, :default => nil
      def declare(cidrblock, availabilityzone, vpcid)
        exitcode=@aws.ec2.subnet.declare(options[:region], vpcid, cidrblock, availabilityzone, options[:availabilitytimeout], @out, (options[:verbose] ? @out : nil), options[:check], options[:undofile])
        exit exitcode if not @print_exit_code
        @out.puts(exitcode)
      end

      desc "delete CIDRBLOCK VPCID", "Delete a subnet if it exists."

      def delete(cidrblock, vpcid)
        @aws.ec2.subnet.delete(options[:region], @out, (options[:verbose] ? @out : nil), vpcid, cidrblock)
      end

    end
  end
end
