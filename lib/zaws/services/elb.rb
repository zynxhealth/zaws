require 'json'
require 'netaddr'
require 'timeout'

module ZAWS
  class ELB

	def initialize(shellout,aws,undofile=nil)
	  @shellout=shellout
	  @aws=aws
		@undofile=undofile
	end

	def load_balancer 
	  @_load_balancer ||= (ZAWS::Services::ELB::LoadBalancer.new(@shellout,@aws,@undofile))
	  return @_load_balancer
	end

  end
end

