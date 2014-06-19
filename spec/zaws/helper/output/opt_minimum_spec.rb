require 'spec_helper'

describe ZAWS::Helper::Output do

  it "output minimum 1 options" do
	output = double ('output')
	output.should_receive(:puts).with("  At mininum, 1 of the following is required:").ordered
    output.should_receive(:puts).with("    --option1").ordered
    output.should_receive(:puts).with("    --option2").ordered
	ZAWS::Helper::Output.opt_minimum(output,1,[:option1,:option2])
  end


end

