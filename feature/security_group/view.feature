Feature: Security Group 
  Security Group(s) are viewable
    
  Scenario: Get security groups in a human readable table. 
    Given I double `aws --output table --region us-west-1 ec2 describe-security-groups` with "AWS Security Group Table Output" 
    When I run `bundle exec zaws security_group view --region us-west-1 --viewtype table`
    Then the stdout should contain "AWS Security Group Table Output\n" 

  Scenario: Get security groups in a human readable table form by default 
    Given I double `aws --output table --region us-west-1 ec2 describe-security-groups` with "AWS Security Group Table Output" 
    When I run `bundle exec zaws security_group view --region us-west-1`
    Then the stdout should contain "AWS Security Group Table Output\n" 

  Scenario: Get security groups in JSON form 
    Given I double `aws --output json --region us-west-1 ec2 describe-security-groups` with "AWS Security Group JSON Output" 
    When I run `bundle exec zaws security_group view --region us-west-1 --viewtype json`
    Then the stdout should contain "AWS Security Group JSON Output\n" 

  Scenario: Get security groups from specified vpcid
    Given I double `aws --output table --region us-west-1 ec2 describe-security-groups --filter 'Name=vpc-id,Values=my_vpc_id'` with "AWS Security Group Table Output" 
    When I run `bundle exec zaws security_group view --region us-west-1 --vpcid my_vpc_id`
    Then the stdout should contain "AWS Security Group Table Output\n"

  Scenario: Get all security groups that are not actively associated to an instance
    Given I double `aws --output json --region us-west-1 ec2 describe-instances` with stdout:
    """
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
              ] } ] }
    """
    And I double `aws --output json --region us-west-1 ec2 describe-security-groups` with stdout:
    """
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
    """
    When I run `bundle exec zaws security_group view --region us-west-1 --unused`
    Then the stdout should contain "default\nmy_unused_group\n"

