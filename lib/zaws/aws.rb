
module ZAWS
  class AWS 

	def initialize(shellout,awscli)
	  @shellout=shellout
	  @_awscli= awscli ? awscli : ZAWS::AWSCLI.new(@shellout)
	end

	def awscli
	  return @_awscli
	end

	def ec2
	  @_ec2 ||= (ZAWS::EC2.new(@shellout,self))
	end
	
	def elb 
	  @_elb ||= (ZAWS::ELB.new(@shellout,self))
	end
	
	def route53
	  @_route53 ||= (ZAWS::Route53.new(@shellout,self))
	end

	def s3
	  @_s3 ||= (ZAWS::S3.new(@shellout,self))
	end
	
	def cloud_trail
	  @_cloud_trail ||= (ZAWS::CloudTrail.new(@shellout,self))
	end

  end
end

