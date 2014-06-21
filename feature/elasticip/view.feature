Feature: Elasticip 
    
  Scenario: Get elasticip in a human readable table. 
    Given I double `aws --output table --region us-west-1 ec2 describe-addresses` with "AWS Elasticip Output" 
    When I run `bundle exec zaws elasticip view --region us-west-1 --viewtype table`
    Then the stdout should contain "AWS Elasticip Output\n" 

  Scenario: Get elasticip in a human readable table form by default 
    Given I double `aws --output table --region us-west-1 ec2 describe-addresses` with "AWS Elasticip Output" 
    When I run `bundle exec zaws elasticip view --region us-west-1`
    Then the stdout should contain "AWS Elasticip Output\n" 

  Scenario: Get elasticip in JSON form 
    Given I double `aws --output json --region us-west-1 ec2 describe-addresses` with "AWS Elasticip JSON Output" 
    When I run `bundle exec zaws elasticip view --region us-west-1 --viewtype json`
    Then the stdout should contain "AWS Elasticip JSON Output\n" 


