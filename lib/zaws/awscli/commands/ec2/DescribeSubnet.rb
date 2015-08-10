module ZAWS
  class AWSCLI
	class Commands
     class EC2
	   class DescribeSubnet

          def initialize(shellout,awscli)
                @shellout=shellout
                @awscli=awscli
          end

          def execute(region,view,filters={},textout=nil,verbose=nil)
			  comline="aws --output #{view} --region #{region} ec2 describe-subnets"
			  comline = comline + " --filter" if filters.length > 0
			  filters.each do |key,item|
				comline = comline + " 'Name=#{key},Values=#{item}'"  
			  end
			  @awscli.data_ec2.subnet.load(comline,@shellout.cli(comline,verbose),textout)
		  end

	   end
      end
	end
  end
end
