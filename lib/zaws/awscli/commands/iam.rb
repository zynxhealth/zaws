module ZAWS
  class AWSCLI
	class Commands
	  class IAM 
		def initialize(shellout,aws)
		  @shellout=shellout
		  @aws=aws
		end

		def getRolePolicy 
		  # http://docs.aws.amazon.com/cli/latest/reference/iam/get-role-policy.html
		  @_getRolePolicy ||= (ZAWS::AWSCLI::Commands::IAM::GetRolePolicy.new(@shellout,@aws))
		  return @_getRolePolicy
		end

		def getPolicy 
		  @_getPolicy ||= (ZAWS::AWSCLI::Commands::IAM::GetPolicy.new(@shellout,@aws))
		  return @_getPolicy
		end

		def getPolicyVersion
		  # http://docs.aws.amazon.com/cli/latest/reference/iam/get-role-policy.html
		  @_getPolicyVersion ||= (ZAWS::AWSCLI::Commands::IAM::GetPolicyVersion.new(@shellout,@aws))
		  return @_getPolicyVersion
		end


	  end
	end
  end
end
