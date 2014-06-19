require 'json'
require 'netaddr'
require 'timeout'

module ZAWS
  class Route53

	def initialize(shellout,aws)
	  @shellout=shellout
	  @aws=aws
	end

	def hosted_zone 
	  @_hosted_zone ||= (ZAWS::Route53Services::HostedZone.new(@shellout,@aws))
	  return @_hosted_zone
	end
		
  end
end

