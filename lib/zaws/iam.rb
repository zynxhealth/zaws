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
	  @_role ||= (ZAWS::Services::IAM::Role.new(@shellout,@aws))
	  return @_role
	end
	
	def policy 
	  @_policy ||= (ZAWS::Services::IAM::Policy.new(@shellout,@aws))
	  return @_policy
	end
	
  end
end

