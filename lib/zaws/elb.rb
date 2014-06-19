require 'json'
require 'netaddr'
require 'timeout'

module ZAWS
  class ELB

	def initialize(shellout,aws)
	  @shellout=shellout
	  @aws=aws
	end

	def load_balancer 
	  @_load_balancer ||= (ZAWS::ELBServices::LoadBalancer.new(@shellout,@aws))
	  return @_load_balancer
	end

  end
end

