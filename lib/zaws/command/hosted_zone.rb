require 'thor'

module ZAWS
  module Command
    class Hosted_Zone < Thor
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

      desc "view", "View hosted zones."
      option :viewtype, :type => :string, :desc => "View type, json or table", :banner => "<viewtype>", :aliases => :w, :default => "table"

      def view
        @aws.route53.hosted_zone.view(options[:viewtype], @out, (options[:verbose] ? @out : nil))
      end

      desc "view_records ZONE_NAME", "View record sets for hosted ZONE_NAME."
      option :viewtype, :type => :string, :desc => "View type, json or table", :banner => "<viewtype>", :aliases => :w, :default => "table"

      def view_records(zonename)
        @aws.route53.hosted_zone.view_records(options[:viewtype], @out, (options[:verbose] ? @out : nil), zonename)
      end

    end
  end
end

	
