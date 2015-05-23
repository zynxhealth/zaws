require 'spec_helper'

describe ZAWS::AWSCLI do

  it "should auto detect version " do

	textout=double('outout')
	shellout=double('ZAWS::Helper::Shell')
	expect(shellout).to receive(:cli).with("aws --version",nil).and_return("aws-cli/1.2.13 Python/2.7.5 Linux/3.10.0-123.el7.x86_64")
	awscli=ZAWS::AWSCLI.new(shellout)
	expect(awscli.version).to eq('aws-cli/1.2.13')

  end

end



