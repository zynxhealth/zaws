
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

  def s3
    @_s3 ||= (ZAWS::S3.new(@shellout,self))
    return @_s3
  end
  
  def cloud_trail
    @_cloud_trail ||= (ZAWS::CloudTrail.new(@shellout,self))
  end

  end
end

