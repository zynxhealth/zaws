module ZAWS
  class AWSCLI
	class Data
	  class EC2
		def initialize(shellout,aws)
		  @shellout=shellout
		  @aws=aws
		end

		def subnet 
		  @_Subnet ||= (ZAWS::AWSCLI::Data::EC2::Subnet.new(@shellout,self))
		  return @_Subnet
		end

	  end
	end
  end
end
