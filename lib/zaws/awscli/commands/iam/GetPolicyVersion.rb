module ZAWS
  class AWSCLI
	class Commands
     class IAM
	   class GetPolicyVersion

          def initialize(shellout,awscli)
                @shellout=shellout
                @awscli=awscli
          end

          def execute(policy_arn,versoin,view,verbose)
              comline="aws --output #{view} iam get-policy-version --policy-arn #{policy_arn} --version-id #{version}"
			  @awscli.data_iam.policy_version.load(comline,@shellout.cli(comline,verbose),verbose)
		  end

	   end
    end
	end
  end
end
