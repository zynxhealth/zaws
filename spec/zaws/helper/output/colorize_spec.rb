require 'spec_helper'

describe ZAWS::Helper::Output do

  it "colorize text red" do
	ZAWS::Helper::Output.colorize("text",AWS_consts::COLOR_RED).should eql("\e[31mtext\e[0m")
  end

  it "colorize text yellow" do
	ZAWS::Helper::Output.colorize("text",AWS_consts::COLOR_YELLOW).should eql("\e[33mtext\e[0m")
  end

  it "colorize text green" do
	ZAWS::Helper::Output.colorize("text",AWS_consts::COLOR_GREEN).should eql("\e[32mtext\e[0m")
  end

  it "colorize text blue" do
	ZAWS::Helper::Output.colorize("text",AWS_consts::COLOR_BLUE).should eql("\e[34mtext\e[0m")
  end

  it "colorize text cyan" do
	ZAWS::Helper::Output.colorize("text",AWS_consts::COLOR_CYAN).should eql("\e[36mtext\e[0m")
  end

  it "colorize text default" do
	ZAWS::Helper::Output.colorize("text",AWS_consts::COLOR_DEFAULT).should eql("\e[39mtext\e[0m")
  end

end

