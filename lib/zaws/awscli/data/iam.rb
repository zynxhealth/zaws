module ZAWS
  class AWSCLI
	class Data
	  class IAM 
		def initialize(shellout,aws)
		  @shellout=shellout
		  @aws=aws
		end

		def rolePolicy 
		  @_RolePolicy ||= (ZAWS::AWSCLI::Data::IAM::RolePolicy.new(@shellout,self))
		  return @_RolePolicy
		end

	  end
	end
  end
end
