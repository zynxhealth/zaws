require 'spec_helper'

describe ZAWS::Helper::Output do

  it "output required options" do
	output = double ('output')
	output.should_receive(:puts).with(' --option1 required!')
	ZAWS::Helper::Output.opt_required(output,[:option1])
  end

end

