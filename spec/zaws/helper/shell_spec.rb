require 'spec_helper'

describe ZAWS::Helper::Shell do

  describe "#cli" do
    it "echo 'text' should return text" do
      shell=ZAWS::Helper::Shell.new
      expect(shell.cli("echo 'text'")).to eq("text\n")
    end

    # Different results on Linux and Windows
    # it "ls_no_such_command should raise an error" do
    # shell=ZAWS::Helper::Shell.new
    # expect {shell.cli("ls_no_such_command")}.to raise_error(Errno::ENOENT)
    # end

    it "grep exit code of 1 should raise an error" do
      shell=ZAWS::Helper::Shell.new
      expect { shell.cli("echo 'lookup' | grep 'lookout'") }.to raise_error(Mixlib::ShellOut::ShellCommandFailed)
    end

    it "grep exit code of 1 should raise an error" do
      shell=ZAWS::Helper::Shell.new
      expect { shell.cli("echo 'lookup' | grep 'lookout'") }.to raise_error(Mixlib::ShellOut::ShellCommandFailed)
    end

    it "should put colorize text to output" do
      shell=ZAWS::Helper::Shell.new
      output = double ('output')
      output.should_receive(:puts).with("\e[34mecho 'text'\e[0m")
      expect(shell.cli("echo 'text'", output)).to eq("text\n")
    end
  end

  describe "#if_then" do
    it "what if true should echo 'text' should return text" do
      shell=ZAWS::Helper::Shell.new
      expect(shell.if_then(true, "echo 'text'")).to eq("text\n")
    end

    it "what if false should return nil" do
      shell=ZAWS::Helper::Shell.new
      expect(shell.if_then(false, "echo 'text'")).to be_nil
    end


    it "what if false should return nil and output command" do
      shell=ZAWS::Helper::Shell.new
      output = double ('output')
      output.should_receive(:puts).with("\e[34mecho 'text'\e[0m")
      expect(shell.if_then(false, "echo 'text'", output)).to be_nil
    end

  end
end

