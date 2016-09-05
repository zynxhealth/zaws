require 'spec_helper'

describe ZAWS::Helper::Output do

  it "does a binary nagios check and reports critical,exit 2 if condition is false" do
	output = double ('output')
	output.should_receive(:puts).with(/critical/)
    expect(ZAWS::Helper::Output.binary_nagios_check(false,"ok","critical",output)).to eq(2)
  end

  it "does a binary nagios check and reports ok,exit 0 if condition is true" do
	output = double ('output')
	output.should_receive(:puts).with(/ok/)
    expect(ZAWS::Helper::Output.binary_nagios_check(true,"ok","critical",output)).to eq(0)
  end


end

