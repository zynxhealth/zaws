Feature: Security Group 
  Security Group(s) are viewable
    
  Scenario: Get security groups in a human readable table. 
    Given I double `aws --output table --region us-west-1 ec2 describe-security-groups` with "AWS Security Group Table Output" 
    When I run `zaws security_group view --region us-west-1 --viewtype table`
    Then the stdout should contain "AWS Security Group Table Output\n" 

  Scenario: Get security groups in a human readable table form by default 
    Given I double `aws --output table --region us-west-1 ec2 describe-security-groups` with "AWS Security Group Table Output" 
    When I run `zaws security_group view --region us-west-1`
    Then the stdout should contain "AWS Security Group Table Output\n" 

  Scenario: Get security groups in JSON form 
    Given I double `aws --output json --region us-west-1 ec2 describe-security-groups` with "AWS Security Group JSON Output" 
    When I run `zaws security_group view --region us-west-1 --viewtype json`
    Then the stdout should contain "AWS Security Group JSON Output\n" 

  Scenario: Get security groups from specified vpcid
    Given I double `aws --output table --region us-west-1 ec2 describe-security-groups --filter 'Name=vpc-id,Values=my_vpc_id'` with "AWS Security Group Table Output" 
    When I run `zaws security_group view --region us-west-1 --vpcid my_vpc_id`
    Then the stdout should contain "AWS Security Group Table Output\n" 
   
