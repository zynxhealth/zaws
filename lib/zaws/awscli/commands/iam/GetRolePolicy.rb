module ZAWS
  class AWSCLI
	class Commands
     class IAM
	   class GetRolePolicy

          def initialize(shellout,awscli)
                @shellout=shellout
                @awscli=awscli
          end

          def execute(role,policy,verbose,textout=nil)
              comline="aws --output json --region #{region} iam get-role-policy --role-name #{role} --policy-name #{policy}"
			  @awscli.data_iam.role_policy.load(comline,@shellout.cli(comline,verbose),textout)
		  end

	   end
    end
	end
  end
end
