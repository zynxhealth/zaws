require 'spec_helper'

describe ZAWS::Services::ELB::LoadBalancer do

  let(:output_json) { "json" }
  let(:region) { "us-west-1" }
  let(:elb_name) { "name-???" }
  let (:vpc_id) { "my_vpc_id" }
  let (:external_id) { "my_instance" }
  let (:security_group_name) { "my_security_group" }
  let (:instance_id) { "i-12345678" }
  let (:instance_id2) { "i-1234567a" }

  let(:describe_load_balancer_json) {
    desc_load_balancers= ZAWS::External::AWSCLI::Commands::ELB::DescribeLoadBalancers.new
    desc_load_balancers.aws.output(output_json).region(region)
    desc_load_balancers
  }

  let(:empty_load_balancer) {
    ZAWS::External::AWSCLI::Generators::Result::ELB::LoadBalancers.new
  }

  let (:security_groups) {
    security_groups = ZAWS::External::AWSCLI::Generators::Result::EC2::SecurityGroups.new
    security_groups.group_name(0, security_group_name).group_id(0, "sg-X")
  }

  let (:instances) {
    tags = ZAWS::External::AWSCLI::Generators::Result::EC2::Tags.new
    tags = tags.add("externalid", instance_id)
    instances = ZAWS::External::AWSCLI::Generators::Result::EC2::Instances.new
    instances.instance_id(0, instance_id).security_groups(0, security_groups).tags(0, tags)
  }

  let (:instances2) {
    tags = ZAWS::External::AWSCLI::Generators::Result::EC2::Tags.new
    tags = tags.add("externalid", instance_id2)
    instances = ZAWS::External::AWSCLI::Generators::Result::EC2::Instances.new
    instances.instance_id(0, instance_id2).security_groups(0, security_groups).tags(0, tags)
  }

  let(:single_load_balancer) {
    listener=ZAWS::External::AWSCLI::Generators::Result::ELB::Listeners.new
    lb= ZAWS::External::AWSCLI::Generators::Result::ELB::LoadBalancers.new
    lb.name(0, elb_name).instances(0, instances).listeners(0,listener)
  }

  let(:single_load_balancer_with_listener) {
    listener=ZAWS::External::AWSCLI::Generators::Result::ELB::Listeners.new
    listener.instance_port(0,80).load_balancer_port(0,80).protocol(0,"HTTP").instance_protocol(0,"HTTP")
    lb= ZAWS::External::AWSCLI::Generators::Result::ELB::LoadBalancers.new
    lb.name(0, elb_name).instances(0, instances).listeners(0,listener)
  }

  let (:describe_instances) {
    tags = ZAWS::External::AWSCLI::Generators::Result::EC2::Tags.new
    tags = tags.add("externalid", instance_id)
    desc_instances = ZAWS::External::AWSCLI::Commands::EC2::DescribeInstances.new
    desc_instances.filter.vpc_id(vpc_id).tags(tags)
    desc_instances.aws.output(output_json).region(region)
    desc_instances
  }

  let (:describe_instances2) {
    tags = ZAWS::External::AWSCLI::Generators::Result::EC2::Tags.new
    tags = tags.add("externalid", instance_id2)
    desc_instances = ZAWS::External::AWSCLI::Commands::EC2::DescribeInstances.new
    desc_instances.filter.vpc_id(vpc_id).tags(tags)
    desc_instances.aws.output(output_json).region(region)
    desc_instances
  }

  let(:ok_elb) { ZAWS::Helper::Output.colorize("OK: Load Balancer Exists.", AWS_consts::COLOR_GREEN) }
  let(:critical_elb) { ZAWS::Helper::Output.colorize("CRITICAL: Load Balancer does not exist.", AWS_consts::COLOR_RED) }
  let(:ok_instance_registered) { ZAWS::Helper::Output.colorize("OK: Instance registerd.", AWS_consts::COLOR_GREEN) }
  let(:critical_instance_registered) { ZAWS::Helper::Output.colorize("CRITICAL: Instance not registered.", AWS_consts::COLOR_RED) }
  let(:ok_listener_exists) { ZAWS::Helper::Output.colorize("OK: Listerner exists.", AWS_consts::COLOR_GREEN) }
  let(:critical_listener_exists) { ZAWS::Helper::Output.colorize("CRITICAL: Listener does not exist.", AWS_consts::COLOR_RED) }

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

    options_json_vpcid = {:region => @var_region,
                          :verbose => false,
                          :check => false,
                          :undofile => false,
                          :viewtype => 'json',
                          :vpcid => vpc_id
    }

    options_json_vpcid_check = {:region => @var_region,
                                :verbose => false,
                                :check => true,
                                :undofile => false,
                                :viewtype => 'json',
                                :vpcid => vpc_id,
                                :cidrblock => '"10.0.0.0/28" "10.0.1.0/28"'
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

    @command_load_balancer_json_vpcid = ZAWS::Command::Load_Balancer.new([], options_json_vpcid, {})
    @command_load_balancer_json_vpcid.aws=@aws
    @command_load_balancer_json_vpcid.out=@textout
    @command_load_balancer_json_vpcid.print_exit_code = true

    @command_load_balancer_json_vpcid_check = ZAWS::Command::Load_Balancer.new([], options_json_vpcid_check, {})
    @command_load_balancer_json_vpcid_check.aws=@aws
    @command_load_balancer_json_vpcid_check.out=@textout
    @command_load_balancer_json_vpcid_check.print_exit_code = true
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

  describe "#exists_instance" do
    context "instance is registered" do
      it "returns true" do
        expect(@shellout).to receive(:cli).with(describe_load_balancer_json.aws.get_command, nil).and_return(single_load_balancer.get_json)
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@textout).to receive(:puts).with('true')
        @command_load_balancer_json_vpcid.exists_instance(elb_name, instance_id)
      end
    end
    context "instance is not registered" do
      it "returns false" do
        expect(@shellout).to receive(:cli).with(describe_load_balancer_json.aws.get_command, nil).and_return(single_load_balancer.get_json)
        expect(@shellout).to receive(:cli).with(describe_instances2.aws.get_command, nil).and_return(instances2.get_json)
        expect(@textout).to receive(:puts).with('false')
        @command_load_balancer_json_vpcid.exists_instance(elb_name, instance_id2)
      end
    end
  end

  describe "#create_in_subnet" do
    context "check flag provided and load balancer created" do
      it "ok" do
        expect(@shellout).to receive(:cli).with(describe_load_balancer_json.aws.get_command, nil).and_return(single_load_balancer.get_json)
        expect(@textout).to receive(:puts).with(ok_elb)
        begin
          @command_load_balancer_json_vpcid_check.create_in_subnet(elb_name, 'tcp', 80, 'tcp', 80, 'my_security_group_name')
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end
    context "check flag provided and load balancer created" do
      it "critical" do
        expect(@shellout).to receive(:cli).with(describe_load_balancer_json.aws.get_command, nil).and_return(empty_load_balancer.get_json)
        expect(@textout).to receive(:puts).with(critical_elb)

        begin
          @command_load_balancer_json_vpcid_check.create_in_subnet(elb_name, 'tcp', 80, 'tcp', 80, 'my_security_group_name')
        rescue SystemExit => e
          expect(e.status).to eq(2)
        end
      end
    end
  end


  describe "#create_in_subnet" do
    context "check flag provided and load balancer created" do
      it "ok" do
        expect(@shellout).to receive(:cli).with(describe_load_balancer_json.aws.get_command, nil).and_return(single_load_balancer.get_json)
        expect(@textout).to receive(:puts).with(ok_elb)
        begin
          @command_load_balancer_json_vpcid_check.create_in_subnet(elb_name, 'tcp', 80, 'tcp', 80, 'my_security_group_name')
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end
    context "check flag provided and load balancer created" do
      it "critical" do
        expect(@shellout).to receive(:cli).with(describe_load_balancer_json.aws.get_command, nil).and_return(empty_load_balancer.get_json)
        expect(@textout).to receive(:puts).with(critical_elb)

        begin
          @command_load_balancer_json_vpcid_check.create_in_subnet(elb_name, 'tcp', 80, 'tcp', 80, 'my_security_group_name')
        rescue SystemExit => e
          expect(e.status).to eq(2)
        end
      end
    end
  end

  describe "#register_instance" do
    context "check flag provided and instance registered" do
      it "ok" do
        expect(@shellout).to receive(:cli).with(describe_load_balancer_json.aws.get_command, nil).and_return(single_load_balancer.get_json)
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@textout).to receive(:puts).with(ok_instance_registered)
        begin
          @command_load_balancer_json_vpcid_check.register_instance(elb_name, instance_id)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end
    context "check flag provided and instance not registered" do
      it "critical" do
        expect(@shellout).to receive(:cli).with(describe_load_balancer_json.aws.get_command, nil).and_return(single_load_balancer.get_json)
        expect(@shellout).to receive(:cli).with(describe_instances2.aws.get_command, nil).and_return(instances2.get_json)
        expect(@textout).to receive(:puts).with(critical_instance_registered)
        begin
          @command_load_balancer_json_vpcid_check.register_instance(elb_name, instance_id2)
        rescue SystemExit => e
          expect(e.status).to eq(2)
        end
      end
    end
  end

  describe "#declare_listener" do
    context "check flag specified and listner on load balancer exists" do
      it "returns ok" do
        expect(@shellout).to receive(:cli).with(describe_load_balancer_json.aws.get_command, nil).and_return(single_load_balancer_with_listener.get_json)
        expect(@textout).to receive(:puts).with(ok_listener_exists)
        begin
          @command_load_balancer_json_vpcid_check.declare_listener(elb_name, "HTTP", 80, "HTTP", 80)
        rescue SystemExit => e
          expect(e.status).to eq(2)
        end
      end
    end
    context "check flag specified and listner not on load balancer exists" do
      it "returns ok" do
        expect(@shellout).to receive(:cli).with(describe_load_balancer_json.aws.get_command, nil).and_return(single_load_balancer.get_json)
        expect(@textout).to receive(:puts).with(critical_listener_exists)
        begin
          @command_load_balancer_json_vpcid_check.declare_listener(elb_name, "HTTP", 80, "HTTP", 80)
        rescue SystemExit => e
          expect(e.status).to eq(2)
        end
      end
    end

  end

end



