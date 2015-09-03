require 'json'
require 'netaddr'
require 'timeout'

module ZAWS
  class IAM 

	def initialize(shellout,aws)
	  @shellout=shellout
	  @aws=aws
	end

	def role 
	  @_role ||= (ZAWS::IAMServices::Role.new(@shellout,@aws))
	  return @_role
	end
	
  end
end

