
module ZAWS
  class AWS 

	def initialize(shellout)
	  @shellout=shellout
	end

	def ec2
	  @_ec2 ||= (ZAWS::EC2.new(@shellout,self))
	  return @_ec2
	end
	
	def elb 
	  @_elb ||= (ZAWS::ELB.new(@shellout,self))
	  return @_elb
	end
	
	def route53
	  @_route53 ||= (ZAWS::Route53.new(@shellout,self))
	  return @_route53
	end

  end
end

