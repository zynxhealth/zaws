require 'spec_helper'

describe ZAWS::ELBServices::LoadBalancer do

  before(:each) {
	@textout=double('outout')
    @shellout=double('ZAWS::Helper::Shell')
    @aws=ZAWS::AWS.new(@shellout,ZAWS::AWSCLI.new(@shellout))
  }

  describe "#calculated_listener" do
	it "Creates a JSON object with a listner definition" do

	  # example output for: aws ec2 escribe-subnets
	  json_expectation = "[{\"Protocol\":\"tcp\",\"LoadBalancerPort\":80,\"InstanceProtocol\":\"tcp\",\"InstancePort\":80}]" 

	  expect(@aws.elb.load_balancer.calculated_listener("tcp","80","tcp","80")).to eql(json_expectation)

	end
  end

end


