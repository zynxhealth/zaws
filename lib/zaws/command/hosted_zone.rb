require 'thor'

module ZAWS
  module Command
	class Hosted_Zone < Thor 
	  class_option :verbose, :type => :boolean, :desc => "Verbose outout", :aliases => :d, :default => false

	  desc "view","View hosted zones."
	  option :viewtype, :type => :string, :desc => "View type, json or table", :banner => "<viewtype>", :aliases => :w, :default => "table"
	  def view
		aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
		aws.route53.hosted_zone.view(options[:viewtype],$stdout,(options[:verbose]?$stdout:nil))
	  end

	  desc "view_records ZONENAME","View record sets for hosted zone name."
	  option :viewtype, :type => :string, :desc => "View type, json or table", :banner => "<viewtype>", :aliases => :w, :default => "table"
	  def view_records(zonename)
		aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
		aws.route53.hosted_zone.view_records(options[:viewtype],$stdout,(options[:verbose]?$stdout:nil),zonename)
	  end

	end
  end
end

	
