require 'spec_helper'

describe ZAWS::EC2Services::Compute do

  it "creates a placement with a zone value only" do

        shellout=double('ZAWS::Helper::Shell')
        aws=ZAWS::AWS.new(shellout)
        expect(aws.ec2.compute.placement_aggregate("zone",nil)).to eq("AvailabilityZone=zone")

  end

  it "creates a placement with a tenancy value only" do

        shellout=double('ZAWS::Helper::Shell')
        aws=ZAWS::AWS.new(shellout)
        expect(aws.ec2.compute.placement_aggregate(nil,"tenancy")).to eq("Tenancy=tenancy")

  end

  it "creates a placement with a zone and a tenancy value " do

        shellout=double('ZAWS::Helper::Shell')
        aws=ZAWS::AWS.new(shellout)
        expect(aws.ec2.compute.placement_aggregate("zone","tenancy")).to eq("AvailabilityZone=zone,Tenancy=tenancy")

  end


end


