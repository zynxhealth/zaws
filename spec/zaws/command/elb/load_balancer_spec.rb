require 'spec_helper'

describe ZAWS::Services::ELB::LoadBalancer do

  let(:output_json) { "json" }
  let(:region) { "us-west-1" }
  let(:elb_name) { "name-???" }

  let(:describe_load_balancer_json) {
    desc_load_balancers= ZAWS::External::AWSCLI::Commands::ELB::DescribeLoadBalancers.new
    desc_load_balancers.aws.output(output_json).region(region)
    desc_load_balancers
  }

  let(:single_load_balancer) {
    lb= ZAWS::External::AWSCLI::Generators::Result::ELB::LoadBalancers.new
    lb.name(0, elb_name)
  }

  let(:empty_load_balancer) {
    lb= ZAWS::External::AWSCLI::Generators::Result::ELB::LoadBalancers.new
  }

  before(:each) {
    @var_security_group_id="sg-abcd1234"
    @var_output_json="json"
    @var_output_table="table"
    @var_region="us-west-1"
    @var_vpc_id="my_vpc_id"
    @var_sec_group_name="my_security_group_name"

    options_json = {:region => @var_region,
                    :verbose => false,
                    :check => false,
                    :undofile => false,
                    :viewtype => 'json'
    }

    options_table = {:region => @var_region,
                     :verbose => false,
                     :check => false,
                     :undofile => false,
                     :viewtype => 'table'
    }


    @textout=double('outout')
    @shellout=double('ZAWS::Helper::Shell')
    @undofile=double('ZAWS::Helper::ZFile')
    @aws=ZAWS::AWS.new(@shellout, ZAWS::AWSCLI.new(@shellout, true), @undofile)
    @command_load_balancer = ZAWS::Command::Load_Balancer.new([], options_table, {})
    @command_load_balancer.aws=@aws
    @command_load_balancer.out=@textout
    @command_load_balancer.print_exit_code = true
    @command_load_balancer_json = ZAWS::Command::Load_Balancer.new([], options_json, {})
    @command_load_balancer_json.aws=@aws
    @command_load_balancer_json.out=@textout
    @command_load_balancer_json.print_exit_code = true
  }

  describe "#view" do
    it "Get load balancer in a human readable table." do
      desc_load_balancers= ZAWS::External::AWSCLI::Commands::ELB::DescribeLoadBalancers.new
      desc_load_balancers.aws.output(@var_output_table).region(@var_region)
      expect(@shellout).to receive(:cli).with(desc_load_balancers.aws.get_command, nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @command_load_balancer.view()
    end

    it "Get load balancer in JSON form " do
      expect(@shellout).to receive(:cli).with(describe_load_balancer_json.aws.get_command, nil).ordered.and_return('test output')
      expect(@textout).to receive(:puts).with('test output').ordered
      @command_load_balancer_json.view()
    end
  end

  describe "#exists" do
    context "Load balancer exists" do
      it "true, it does exist" do
        expect(@shellout).to receive(:cli).with(describe_load_balancer_json.aws.get_command, nil).and_return(single_load_balancer.get_json)
        expect(@textout).to receive(:puts).with('true')
        @command_load_balancer_json.exists(elb_name)
      end
    end
    context "Load balancer does not exist" do
      it "false, it does not exist" do
        expect(@shellout).to receive(:cli).with(describe_load_balancer_json.aws.get_command, nil).and_return(empty_load_balancer.get_json)
        expect(@textout).to receive(:puts).with('false')
        @command_load_balancer_json.exists(elb_name)
      end
    end
  end

  describe "#calculated_listener" do
    it "Creates a JSON object with a listner definition" do

      # example output for: aws ec2 escribe-subnets
      json_expectation = "[{\"Protocol\":\"tcp\",\"LoadBalancerPort\":80,\"InstanceProtocol\":\"tcp\",\"InstancePort\":80}]"

      expect(@aws.elb.load_balancer.calculated_listener("tcp", "80", "tcp", "80")).to eql(json_expectation)

    end
  end

end



