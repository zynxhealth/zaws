Feature: Compute 
    
  Scenario: Get compute instances in a human readable table. 
    Given I double `aws --output table --region us-west-1 ec2 describe-instances` with "AWS Compute Output" 
    When I run `zaws compute view --region us-west-1 --viewtype table`
    Then the stdout should contain "AWS Compute Output\n" 

  Scenario: Get compute instances in a human readable table form by default 
    Given I double `aws --output table --region us-west-1 ec2 describe-instances` with "AWS Compute Output" 
    When I run `zaws compute view --region us-west-1`
    Then the stdout should contain "AWS Compute Output\n" 

  Scenario: Get compute instances in JSON form 
    Given I double `aws --output json --region us-west-1 ec2 describe-instances` with "AWS Compute JSON Output" 
    When I run `zaws compute view --region us-west-1 --viewtype json`
    Then the stdout should contain "AWS Compute JSON Output\n" 

  Scenario: Get compute instances from specified vpcid
    Given I double `aws --output table --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id'` with "AWS Compute Output" 
    When I run `zaws compute view --region us-west-1 --vpcid my_vpc_id`
    Then the stdout should contain "AWS Compute Output\n" 
		
 
