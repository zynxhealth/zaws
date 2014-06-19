require 'spec_helper'

describe ZAWS::EC2Services::Compute do 

  it "determines an instance is reachable over the network with ping" do

	shellout=double('ZAWS::Helper::Shell')
    comline ='ping -q -c 2 0.0.0.0'
	times_called = 0
    shellout.stub(:cli).with(comline,nil).and_return do
        times_called += 1
        raise Mixlib::ShellOut::ShellCommandFailed if times_called == 2
    end
	aws=ZAWS::AWS.new(shellout)
	aws.ec2.compute.instance_ping?('0.0.0.0',10,1)

  end

  it "determines an instance is not reachable over the network with ping" do

	shellout=double('ZAWS::Helper::Shell')
    comline ='ping -q -c 2 0.0.0.0'
	times_called = 0
    shellout.stub(:cli).with(comline,nil).and_return do
        times_called += 1
        raise Mixlib::ShellOut::ShellCommandFailed if times_called < 4
    end
	aws=ZAWS::AWS.new(shellout)
	expect {aws.ec2.compute.instance_ping?('0.0.0.0',2,1)}.to raise_error(StandardError, 'Timeout before instance responded to ping.')
  end

end


