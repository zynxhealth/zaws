require 'json'
require 'netaddr'
require 'timeout'

module ZAWS
  class EC2

	def initialize(shellout,aws)
	  @shellout=shellout
	  @aws=aws
	end

	def subnet 
	  @_subnet ||= (ZAWS::EC2Services::Subnet.new(@shellout,@aws))
	  return @_subnet
	end
	
	def security_group
	  @_security_group ||= (ZAWS::EC2Services::SecurityGroup.new(@shellout,@aws))
	  return @_security_group
	end

	def route_table 
	  @_route_table ||= (ZAWS::EC2Services::RouteTable.new(@shellout,@aws))
	  return @_route_table
	end
	
	def compute 
	  @_compute ||= (ZAWS::EC2Services::Compute.new(@shellout,@aws))
	  return @_compute
	end
		
	def elasticip 
	  @_elasticip ||= (ZAWS::EC2Services::Elasticip.new(@shellout,@aws))
	  return @_elasticip
	end
	
  end
end

