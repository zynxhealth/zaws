module ZAWS
  class AWSCLI
	class Commands
     class EC2
	   class CreateSubnet

          def initialize(shellout,awscli)
                @shellout=shellout
                @awscli=awscli
          end

          def execute(region,vpcid,cidrblock,availabilityzone,verbose,textout=nil)
              comline="aws --output json --region #{region} ec2 create-subnet --vpc-id #{vpcid} --cidr-block #{cidrblock} --availability-zone #{availabilityzone}"
			  @awscli.data_ec2.subnet.load(comline,@shellout.cli(comline,verbose),textout)
		  end

	   end
    end
	end
  end
end
