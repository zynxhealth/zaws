module ZAWS
  class AWSCLI
	class Commands
     class IAM
	   class GetPolicy

          def initialize(shellout,awscli)
                @shellout=shellout
                @awscli=awscli
          end

          def execute(policy_arn,view,verbose)
              comline="aws --output #{view} iam get-policy --policy-arn #{policy_arn}"
			  @awscli.data_iam.policy.load(comline,@shellout.cli(comline,verbose),verbose)
		  end

	   end
    end
	end
  end
end
