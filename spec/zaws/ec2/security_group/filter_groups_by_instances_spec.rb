require 'spec_helper'

describe ZAWS::EC2 do

  it 'security group id by group name' do

    security_groups_raw = <<-eos
        { "SecurityGroups": [
            {
                "GroupName": "my_group_name",
                "VpcId": "vpc-12345678",
                "OwnerId": "123456789012",
                "GroupId": "sg-C2345678"
            },
            {
                "GroupName": "default",
                "VpcId": "vpc-1f6bb57a",
                "OwnerId": "939117536548",
                "GroupId": "sg-B2345678"
            },
            {
                "GroupName": "my_unused_group",
                "VpcId": "vpc-12345678",
                "OwnerId": "123456789012",
                "GroupId": "sg-A2345678"
            }
        ] }
    eos

    instances_raw = <<-eos
	      { "Reservations": [
              {   "Instances": [
                      {   "InstanceId": "i-12345678",
                          "SecurityGroups": [
                              {
                                  "GroupName": "my_group_name",
                                  "GroupId": "sg-C2345678"
                              }
                          ],
                          "NetworkInterfaces": [
                              {
                                  "NetworkInterfaceId": "eni-12345678",
                                  "Groups": [
                                      {
                                          "GroupName": "my_group_name",
                                          "GroupId": "sg-C2345678"
                                      }
                                  ]
                              }
                          ]
                      }
              ] }
        ] }
    eos

    security_groups_filtered = '{"SecurityGroups":[{"GroupName":"default","VpcId":"vpc-1f6bb57a","OwnerId":"939117536548","GroupId":"sg-B2345678"},{"GroupName":"my_unused_group","VpcId":"vpc-12345678","OwnerId":"123456789012","GroupId":"sg-A2345678"}]}'

    shellout=double('ZAWS::Helper::Shell')
    aws=ZAWS::AWS.new(shellout)
    expect(aws.ec2.security_group.filter_groups_by_instances(security_groups_raw,instances_raw)).to eq(security_groups_filtered)

  end

end