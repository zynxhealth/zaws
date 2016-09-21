require 'spec_helper'

describe ZAWS::Services::ELB::LoadBalancer do

  let(:load_balancer_created) { ZAWS::Helper::Output.colorize("Load balancer created.", AWS_consts::COLOR_YELLOW) }
   let(:load_balancer_not_created) { ZAWS::Helper::Output.colorize("Load balancer already exists. Skipping creation.", AWS_consts::COLOR_GREEN) }

  let(:instance_not_registratered) { ZAWS::Helper::Output.colorize("Instance already registered. Skipping registration.", AWS_consts::COLOR_GREEN) }
  let(:instance_registered) { ZAWS::Helper::Output.colorize("New instance registered.", AWS_consts::COLOR_YELLOW) }

  let(:instance_not_deregistered) { ZAWS::Helper::Output.colorize("Instance not registered. Skipping deregistration.", AWS_consts::COLOR_GREEN) }
  let(:instance_deregistered) { ZAWS::Helper::Output.colorize("Instance deregistered.", AWS_consts::COLOR_YELLOW) }

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


  let(:describe_security_groups_by_name_by_vpcid) {
    desc_sec_grps = ZAWS::External::AWSCLI::Commands::EC2::DescribeSecurityGroups.new
    desc_sec_grps.filter.group_name(security_group_name).vpc_id(vpc_id)
    desc_sec_grps.aws.output(output_json).region(region)
    desc_sec_grps }

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
    lb.name(0, elb_name).instances(0, instances).listeners(0, listener)
  }

  let(:single_load_balancer_with_listener) {
    listener=ZAWS::External::AWSCLI::Generators::Result::ELB::Listeners.new
    listener.instance_port(0, 80).load_balancer_port(0, 80).protocol(0, "HTTP").instance_protocol(0, "HTTP")
    lb= ZAWS::External::AWSCLI::Generators::Result::ELB::LoadBalancers.new
    lb.name(0, elb_name).instances(0, instances).listeners(0, listener)
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

  let (:register_instances_with_load_balancer) {
    riwlb = ZAWS::External::AWSCLI::Commands::ELB::RegisterInstancesWithLoadBalancer.new
    riwlb.aws.region(region)
    riwlb.load_balancer_name(elb_name).instances(instance_id2)
  }

  let (:deregister_instances_with_load_balancer) {
    riwlb = ZAWS::External::AWSCLI::Commands::ELB::DeregisterInstancesWithLoadBalancer.new
    riwlb.aws.region(region)
    riwlb.load_balancer_name(elb_name).instances(instance_id)
  }

  let (:subnets1) {
    subnets = ZAWS::External::AWSCLI::Generators::Result::EC2::Subnets.new
    subnets = subnets.vpc_id(0, vpc_id).cidr_block(0, "10.0.0.0/24").map_public_ip_on_launch(0, false)
    subnets = subnets.default_for_az(0, false).state(0, "available").subnet_id(0, "subnet-YYYYYY")
    @subnets_exists = subnets.available_ip_address_count(0, 251)
  }

  let (:subnets2) {
    subnets = ZAWS::External::AWSCLI::Generators::Result::EC2::Subnets.new
    subnets = subnets.vpc_id(0, vpc_id).cidr_block(0, "10.0.1.0/24").map_public_ip_on_launch(0, false)
    subnets = subnets.default_for_az(0, false).state(0, "available").subnet_id(0, "subnet-ZZZZZZ")
    @subnets_exists2 = subnets.available_ip_address_count(0, 251)
  }


  let(:aws_desc_subnets_by_vpcid_and_cidr) {
    desc_subnets = ZAWS::External::AWSCLI::Commands::EC2::DescribeSubnets.new
    desc_subnets.filter.vpc_id(vpc_id).cidr("10.0.0.0/24")
    desc_subnets.aws.output("json").region(region)
    desc_subnets
  }

  let(:aws_desc_subnets_by_vpcid_and_cidr_2) {
    desc_subnets = ZAWS::External::AWSCLI::Commands::EC2::DescribeSubnets.new
    desc_subnets.filter.vpc_id(vpc_id).cidr("10.0.1.0/24")
    desc_subnets.aws.output("json").region(region)
    desc_subnets
  }

  let(:create_load_balancer) {
    clb = ZAWS::External::AWSCLI::Commands::ELB::CreateLoadBalancer.new
    listener=ZAWS::External::AWSCLI::Generators::Result::ELB::Listeners.new
    listener.protocol(0, "tcp").load_balancer_port(0, 80).instance_protocol(0, "tcp").instance_port(0, 80)
    clb.subnets([ 'subnet-YYYYYY', 'subnet-ZZZZZZ']).security_groups(["sg-X"])
    clb.aws.region(region)
    clb.listeners(listener.get_listeners_array).load_balancer_name('name-???')
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
                          :vpcid => vpc_id,
                          :cidrblocks => ["10.0.0.0/24","10.0.1.0/24"]
    }

    options_json_vpcid_check = {:region => @var_region,
                                :verbose => false,
                                :check => true,
                                :undofile => false,
                                :viewtype => 'json',
                                :vpcid => vpc_id,
                                :cidrblock => '"10.0.0.0/28" "10.0.1.0/28"'
    }

    options_json_vpcid_undo = {:region => @var_region,
                               :verbose => false,
                               :check => true,
                               :undofile => 'undo.sh',
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

    @command_load_balancer_json_vpcid_undo = ZAWS::Command::Load_Balancer.new([], options_json_vpcid_undo, {})
    @command_load_balancer_json_vpcid_undo.aws=@aws
    @command_load_balancer_json_vpcid_undo.out=@textout
    @command_load_balancer_json_vpcid_undo.print_exit_code = true
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
    context "load balancer does not exist" do
      it "create load balancer" do
        expect(@shellout).to receive(:cli).with(describe_load_balancer_json.aws.get_command, nil).and_return(empty_load_balancer.get_json)
        expect(@shellout).to receive(:cli).with(aws_desc_subnets_by_vpcid_and_cidr.aws.get_command, nil).and_return(subnets1.get_json)
        expect(@shellout).to receive(:cli).with(aws_desc_subnets_by_vpcid_and_cidr_2.aws.get_command, nil).and_return(subnets2.get_json)
        expect(@shellout).to receive(:cli).with(describe_security_groups_by_name_by_vpcid.aws.get_command, nil).and_return(security_groups.get_json)
        expect(@shellout).to receive(:cli).with(create_load_balancer.aws.get_command, nil).and_return('{ "DNSName": "???.us-west-1.elb.amazonaws.com" }')
        expect(@textout).to receive(:puts).with(load_balancer_created)

        begin
          @command_load_balancer_json_vpcid.create_in_subnet(elb_name, 'tcp', 80, 'tcp', 80, 'my_security_group')
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end
        context "load balancer does exist" do
      it "skip creating load balancer" do
                expect(@shellout).to receive(:cli).with(describe_load_balancer_json.aws.get_command, nil).and_return(single_load_balancer.get_json)
        expect(@textout).to receive(:puts).with(load_balancer_not_created)

        begin
          @command_load_balancer_json_vpcid.create_in_subnet(elb_name, 'tcp', 80, 'tcp', 80, 'my_security_group')
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end
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
    context "check flag provided and load not balancer created" do
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

  describe "#deregister_instance" do
    context "instance registered" do
      it "deregister it" do
        expect(@shellout).to receive(:cli).with(describe_load_balancer_json.aws.get_command, nil).and_return(single_load_balancer.get_json)
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@shellout).to receive(:cli).with(deregister_instances_with_load_balancer.aws.get_command, nil).and_return('{ "return" : "true" }')
        expect(@textout).to receive(:puts).with(instance_deregistered)
        @command_load_balancer_json_vpcid.deregister_instance(elb_name, instance_id)
      end
    end
    context "instance not registered" do
      it "nothing to do" do
        expect(@shellout).to receive(:cli).with(describe_load_balancer_json.aws.get_command, nil).and_return(single_load_balancer.get_json)
        expect(@shellout).to receive(:cli).with(describe_instances2.aws.get_command, nil).and_return(instances2.get_json)
        expect(@textout).to receive(:puts).with(instance_not_deregistered)
        @command_load_balancer_json_vpcid.deregister_instance(elb_name, instance_id2)
      end
    end
  end

  describe "#register_instance" do
    context "instance registered" do
      it "skip, because it exists already" do
        expect(@shellout).to receive(:cli).with(describe_load_balancer_json.aws.get_command, nil).and_return(single_load_balancer.get_json)
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@textout).to receive(:puts).with(instance_not_registratered)
        begin
          @command_load_balancer_json_vpcid.register_instance(elb_name, instance_id)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end
    context "instance not registered" do
      it "instance registered" do
        expect(@shellout).to receive(:cli).with(describe_load_balancer_json.aws.get_command, nil).and_return(single_load_balancer.get_json)
        expect(@shellout).to receive(:cli).with(describe_instances2.aws.get_command, nil).and_return(instances2.get_json)
        expect(@shellout).to receive(:cli).with(register_instances_with_load_balancer.aws.get_command, nil).and_return({"Instances" => instances2.get_instances_array}.to_json)
        expect(@textout).to receive(:puts).with(instance_registered)
        begin
          @command_load_balancer_json_vpcid.register_instance(elb_name, instance_id2)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end
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
    context "undo file provided and instance registered" do
      it "output delete statement to undo file" do
        expect(@undofile).to receive(:prepend).with("zaws load_balancer deregister_instance #{elb_name} #{instance_id} --region #{region} --vpcid my_vpc_id $XTRA_OPTS", '#Deregister instance', 'undo.sh')
        expect(@shellout).to receive(:cli).with(describe_load_balancer_json.aws.get_command, nil).and_return(single_load_balancer.get_json)
        expect(@shellout).to receive(:cli).with(describe_instances.aws.get_command, nil).and_return(instances.get_json)
        expect(@textout).to receive(:puts).with(ok_instance_registered)
        begin
          @command_load_balancer_json_vpcid_undo.register_instance(elb_name, instance_id)
        rescue SystemExit => e
          expect(e.status).to eq(0)
        end
      end
    end

  end

  describe "#exists_listener" do
    context "listener on load balancer exists" do
      it "returns true" do
        expect(@shellout).to receive(:cli).with(describe_load_balancer_json.aws.get_command, nil).and_return(single_load_balancer_with_listener.get_json)
        expect(@textout).to receive(:puts).with('true')
        @command_load_balancer_json_vpcid.exists_listener(elb_name, "HTTP", 80, "HTTP", 80)
      end
    end
    context "no listner on load balancer exists" do
      it "returns false" do
        expect(@shellout).to receive(:cli).with(describe_load_balancer_json.aws.get_command, nil).and_return(single_load_balancer.get_json)
        expect(@textout).to receive(:puts).with('false')
        @command_load_balancer_json_vpcid.exists_listener(elb_name, "HTTP", 80, "HTTP", 80)
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



