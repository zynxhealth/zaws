require 'spec_helper'

# Assume as of now that this format code will be done in output.rb
describe ZAWS::Helper::Output do

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