require 'json'
require 'netaddr'
require 'timeout'

module ZAWS
  class EC2

	def initialize(shellout,aws,undofile=nil)
	  @shellout=shellout
	  @aws=aws
		@undofile=undofile
	end

	def vpc
	  @_vpc ||= (ZAWS::Services::EC2::VPC.new(@shellout,@aws))
	  return @_vpc
	end

	def subnet 
	  @_subnet ||= (ZAWS::Services::EC2::Subnet.new(@shellout,@aws,@undofile))
	  return @_subnet
	end
	
	def security_group
	  @_security_group ||= (ZAWS::Services::EC2::SecurityGroup.new(@shellout,@aws,@undofile))
	  return @_security_group
	end

	def route_table 
	  @_route_table ||= (ZAWS::Services::EC2::RouteTable.new(@shellout,@aws))
	  return @_route_table
	end
	
	def compute 
	  @_compute ||= (ZAWS::Services::EC2::Compute.new(@shellout,@aws))
	  return @_compute
	end
		
	def elasticip 
	  @_elasticip ||= (ZAWS::Services::EC2::Elasticip.new(@shellout,@aws))
	  return @_elasticip
	end
	
  end
end

