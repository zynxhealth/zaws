module ZAWS
  class AWSCLI
	class Data
	  class IAM 
		def initialize(shellout,aws)
		  @shellout=shellout
		  @aws=aws
		end

		def role_policy 
		  @_role_policy ||= (ZAWS::AWSCLI::Data::IAM::RolePolicy.new(@shellout,self))
		  return @_role_policy
		end

	  end
	end
  end
end
