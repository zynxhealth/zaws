module ZAWS
  class AWSCLI
	class Commands
	  class IAM 
		def initialize(shellout,aws)
		  @shellout=shellout
		  @aws=aws
		end

		def GetRolePolicy 
		  # http://docs.aws.amazon.com/cli/latest/reference/iam/get-role-policy.html
		  @_getRolePolicy ||= (ZAWS::AWSCLI::Commands::IAM::GetRolePolicy.new(@shellout,@aws))
		  return @_getRolePolicy
		end

	  end
	end
  end
end
