require 'spec_helper'

describe ZAWS::Helper::Shell do

  it "echo 'text' should return text" do
	shell=ZAWS::Helper::Shell.new
	expect(shell.cli("echo 'text'")).to eq("text\n")
  end

  it "ls_no_such_command should raise an error" do
	shell=ZAWS::Helper::Shell.new
	expect {shell.cli("ls_no_such_command")}.to raise_error(Errno::ENOENT)
  end

  it "grep exit code of 1 should raise an error" do
	shell=ZAWS::Helper::Shell.new
	expect {shell.cli("echo 'lookup' | grep 'lookout'")}.to raise_error(Mixlib::ShellOut::ShellCommandFailed)
  end

  it "grep exit code of 1 should raise an error" do
	shell=ZAWS::Helper::Shell.new
	expect {shell.cli("echo 'lookup' | grep 'lookout'")}.to raise_error(Mixlib::ShellOut::ShellCommandFailed)
  end

  it "should put colorize text to output" do
	shell=ZAWS::Helper::Shell.new
	output = double ('output')
	output.should_receive(:puts).with("\e[34mecho 'text'\e[0m")
	expect(shell.cli("echo 'text'",output)).to eq("text\n")
  end

end

