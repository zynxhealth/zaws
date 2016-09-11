module ZAWS
  class AWSCLI
	class Commands
	  class EC2
		def initialize(shellout,aws)
		  @shellout=shellout
		  @aws=aws
		end

		def createSubnet
		  @_createSubnet ||= (ZAWS::External::AWSCLI::Commands::EC2::CreateSubnet.new(@shellout,@aws))
		  return @_createSubnet
		end

		def describeSubnets
		  @_describeSubnets ||= (ZAWS::External::AWSCLI::Commands::EC2::DescribeSubnets.new(@shellout,@aws))
		  return @_describeSubnets
		end

		def describeSecurityGroups
		  @_describeSecurityGroups ||= (ZAWS::External::AWSCLI::Commands::EC2::DescribeSecurityGroups.new(@shellout,@aws))
		  return @_describeSecurityGroups
		end

		def deleteSubnet
		  @_deleteSubnet ||= (ZAWS::External::AWSCLI::Commands::EC2::DeleteSubnet.new(@shellout,@aws))
		  return @_deleteSubnet
		end

				def deleteSecurityGroup
		  @_deleteSecurityGroup ||= (ZAWS::External::AWSCLI::Commands::EC2::DeleteSecurityGroup.new(@shellout,@aws))
		  return @_deleteSecurityGroup
		end

		def describeVPCs
		  @_describeVPCs ||= (ZAWS::AWSCLI::Commands::EC2::DescribeVPCs.new(@shellout,@aws))
		  return @_describeVPCs
		end

		def describeVpcPeeringConnections
		  @_describeVpcPeeringConnections ||= (ZAWS::AWSCLI::Commands::EC2::DescribeVpcPeeringConnections.new(@shellout,@aws))
		  return @_describeVpcPeeringConnections
		end

		def createVPC
		  @_createVPC ||= (ZAWS::AWSCLI::Commands::EC2::CreateVPC.new(@shellout,@aws))
		  return @_createVPC
		end

		def describeInstances 
		  @_describeInstances ||= (ZAWS::AWSCLI::Commands::EC2::DescribeInstances.new(@shellout,@aws))
		  return @_describeInstances
		end

		def runInstances 
		  @_runInstances ||= (ZAWS::AWSCLI::Commands::EC2::RunInstances.new(@shellout,@aws))
		  return @_runInstances
		end

		def stopInstances 
		  @_stopInstances ||= (ZAWS::AWSCLI::Commands::EC2::StopInstances.new(@shellout,@aws))
		  return @_stopInstances
		end

		def createTags 
		  @_createTags ||= (ZAWS::External::AWSCLI::Commands::EC2::CreateTags.new(@shellout,@aws))
		  return @_createTags
		end


	  end
	end
  end
end
