module ZAWS
  class AWSCLI
	class Commands
     class EC2
	   class RunInstances

          def initialize(shellout,awscli)
                @shellout=shellout
                @awscli=awscli
          end

          def execute(instanceid, region, textout=nil, verbose=nil)
			  comline="aws --output json --region #{region} ec2 start-instances --instance-ids #{instanceid}"
              @shellout.cli(comline,verbose)
		  end

	   end
      end
	end
  end
end
