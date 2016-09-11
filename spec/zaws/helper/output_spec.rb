require 'spec_helper'

describe ZAWS::Helper::Output do

  describe "#binary_nagios_check" do
    it "does a binary nagios check and reports critical,exit 2 if condition is false" do
      output = double ('output')
      output.should_receive(:puts).with(/critical/)
      expect(ZAWS::Helper::Output.binary_nagios_check(false, "ok", "critical", output)).to eq(2)
    end

    it "does a binary nagios check and reports ok,exit 0 if condition is true" do
      output = double ('output')
      output.should_receive(:puts).with(/ok/)
      expect(ZAWS::Helper::Output.binary_nagios_check(true, "ok", "critical", output)).to eq(0)
    end
  end

  describe "#colorize" do

    it "colorize text red" do
      ZAWS::Helper::Output.colorize("text", AWS_consts::COLOR_RED).should eql("\e[31mtext\e[0m")
    end

    it "colorize text yellow" do
      ZAWS::Helper::Output.colorize("text", AWS_consts::COLOR_YELLOW).should eql("\e[33mtext\e[0m")
    end

    it "colorize text green" do
      ZAWS::Helper::Output.colorize("text", AWS_consts::COLOR_GREEN).should eql("\e[32mtext\e[0m")
    end

    it "colorize text blue" do
      ZAWS::Helper::Output.colorize("text", AWS_consts::COLOR_BLUE).should eql("\e[34mtext\e[0m")
    end

    it "colorize text cyan" do
      ZAWS::Helper::Output.colorize("text", AWS_consts::COLOR_CYAN).should eql("\e[36mtext\e[0m")
    end

    it "colorize text default" do
      ZAWS::Helper::Output.colorize("text", AWS_consts::COLOR_DEFAULT).should eql("\e[39mtext\e[0m")
    end
  end

  describe "#opt_exclusive" do

    it "output exclusive options" do
      output = double ('output')
      output.should_receive(:puts).with("  These options cannot be combined:").ordered
      output.should_receive(:puts).with("    --option1").ordered
      output.should_receive(:puts).with("    --option2").ordered
      ZAWS::Helper::Output.opt_exclusive(output, [:option1, :option2])
    end
  end

  describe "#opt_minimum" do
    it "output minimum 1 options" do
      output = double ('output')
      output.should_receive(:puts).with("  At mininum, 1 of the following is required:").ordered
      output.should_receive(:puts).with("    --option1").ordered
      output.should_receive(:puts).with("    --option2").ordered
      ZAWS::Helper::Output.opt_minimum(output, 1, [:option1, :option2])
    end
  end

  describe "#opt_required" do
    it "output required options" do
      output = double ('output')
      output.should_receive(:puts).with(' --option1 required!')
      ZAWS::Helper::Output.opt_required(output, [:option1])
    end
  end

  describe "#cloudtrail" do
    it "should get_default_components in csv format" do

      cloud_trail = <<eos
        {
        "Records": [{
            "userIdentity": {
                "userName": "name-1"
            },
            "eventTime": "event-1",
            "eventSource": "source-1",
            "eventName": "event-name-1"
        }, {
            "userIdentity": {
                "userName": "name-2"
            },
            "eventTime": "event-2",
            "eventSource": "source-2",
            "eventName": "event-name-2"
        }]
    }
eos
      expected_string = "name-1, event-1, source-1, event-name-1\nname-2, event-2, source-2, event-name-2\n"
      ZAWS::Helper::Output.cloudtrail(cloud_trail).should eql(expected_string)
    end

    it "should get error code and error message in csv" do
      cloud_trail = <<eos
    {
        "Records": [{
            "userIdentity": {
                "userName": "name-1"
            },
            "eventTime": "event-1",
            "eventSource": "source-1",
            "eventName": "event-name-1"
        }, {
            "userIdentity": {
                "userName": "name-2"
            },
            "eventTime": "event-2",
            "eventSource": "source-2",
            "eventName": "event-name-2",
            "errorCode": "some-code",
            "errorMessage": "some-message"
        }]
    }
eos
      expected_string = "name-1, event-1, source-1, event-name-1\n"
      expected_string << "name-2, event-2, source-2, event-name-2, some-code, some-message\n"

      ZAWS::Helper::Output.cloudtrail(cloud_trail).should eql(expected_string)
    end

    it "should return cloud trail json if format is raw" do
      cloud_trail = <<eos
    {
        "Records": [{
            "a": "A",
            "b": "B",
            "c": "C"
        }]
    }
eos

      ZAWS::Helper::Output.cloudtrail(cloud_trail, "raw").should eql(cloud_trail)
    end
  end
end

