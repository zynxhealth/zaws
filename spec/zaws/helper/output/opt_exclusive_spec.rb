require 'spec_helper'

describe ZAWS::Helper::Output do

  it "output exclusive options" do
	output = double ('output')
	output.should_receive(:puts).with("  These options cannot be combined:").ordered
    output.should_receive(:puts).with("    --option1").ordered
    output.should_receive(:puts).with("    --option2").ordered
	ZAWS::Helper::Output.opt_exclusive(output,[:option1,:option2])
  end

end

