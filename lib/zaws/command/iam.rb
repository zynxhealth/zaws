require 'thor'

module ZAWS
  module Command
	class IAM < Thor 
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

	  desc "view_role_policy","View compute instances."
	  option :viewtype, :type => :string, :desc => "View type, json or table", :banner => "<viewtype>", :aliases => :w, :default => "table"
	  def view_role_policy(role,policy)
		@aws.iam.role.view_policy(role,policy,options[:viewtype],@out,options[:verbose]?@out:nil)
	  end

	end
  end
end

	
