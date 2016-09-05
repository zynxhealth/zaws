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

		def policy 
		  @_policy ||= (ZAWS::AWSCLI::Data::IAM::Policy.new(@shellout,self))
		  return @_policy
		end

		def policy_document 
		  @_policy_document ||= (ZAWS::AWSCLI::Data::IAM::PolicyDocument.new(@shellout,self))
		  return @_policy_document
		end

		def policy_version 
		  @_policy_version ||= (ZAWS::AWSCLI::Data::IAM::PolicyVersion.new(@shellout,self))
		  return @_policy_version
		end


	  end
	end
  end
end
