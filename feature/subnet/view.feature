Feature: Subnet
  Subnets should be createable once in a specific availability zone.
    
  Scenario: Get subnets in json 
    Given I double `aws --output json --region us-west-1 ec2 describe-subnets` with "< AWS Subnet Json Output >" 
    When I run `bundle exec zaws subnet view --region us-west-1 --viewtype json`
    Then the stdout should contain "< AWS Subnet Json Output >\n" 

  Scenario: Get subnets in table form by default 
    Given I double `aws --output table --region us-west-1 ec2 describe-subnets` with "< AWS Subnet Table Output >" 
    When I run `bundle exec zaws subnet view --region us-west-1`
    Then the stdout should contain "< AWS Subnet Table Output >\n" 

  Scenario: Get subnets in table form when specified 
    Given I double `aws --output table --region us-west-1 ec2 describe-subnets` with "< AWS Subnet Table Output >" 
    When I run `bundle exec zaws subnet view --region us-west-1 --viewtype table`
    Then the output should contain "< AWS Subnet Table Output >\n" 

  Scenario: Get subnets from specified vpcid
    Given I double `aws --output table --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=my_vpc_id'` with "< AWS Subnet Table Output >" 
    When I run `bundle exec zaws subnet view --region us-west-1 --vpcid my_vpc_id`
    Then the output should contain "< AWS Subnet Table Output >\n" 


