require 'json'
require 'netaddr'
require 'timeout'

module ZAWS
  module IAMServices
	class Policy 

	  def initialize(shellout,aws)
		@shellout=shellout
		@aws=aws
	  end

	  def view_default_policy(policy_arn,view,textout,verbose)
		@aws.awscli.command_iam.getPolicy.execute(policy_arn,view,verbose)
		version=@aws.awscli.data_iam.policy.defaultVersion
		@aws.awscli.command_iam.getPolicyVersion.execute(policy_arn,version,view,verbose)
		textout.puts(@aws.awscli.data_iam.policy_doc.view())
	  end

	end
  end
end
