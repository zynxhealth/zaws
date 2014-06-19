require 'spec_helper'

describe ZAWS::Helper::Shell do

  it "what if true should echo 'text' should return text" do
    shell=ZAWS::Helper::Shell.new
	expect(shell.if_then(true,"echo 'text'")).to eq("text\n")
  end

  it "what if false should return nil" do
    shell=ZAWS::Helper::Shell.new
	expect(shell.if_then(false,"echo 'text'")).to be_nil 
  end


  it "what if false should return nil and output command" do
    shell=ZAWS::Helper::Shell.new
    output = double ('output')
	output.should_receive(:puts).with("\e[34mecho 'text'\e[0m")
	expect(shell.if_then(false,"echo 'text'",output)).to be_nil 
  end

end

