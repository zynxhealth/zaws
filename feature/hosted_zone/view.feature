Feature: Hosted Zone 
    
  Scenario: Get hosted zone in a human readable table. 
    Given I double `aws --output table route53 list-hosted-zones` with "AWS Hosted Zone Output" 
    When I run `bundle exec zaws hosted_zone view --viewtype table`
    Then the stdout should contain "AWS Hosted Zone Output\n" 

  Scenario: Get hosted zone in a human readable table form by default 
    Given I double `aws --output table route53 list-hosted-zones` with "AWS Hosted Zone Output" 
    When I run `bundle exec zaws hosted_zone view`
    Then the stdout should contain "AWS Hosted Zone Output\n" 

  Scenario: Get hosted zone in JSON form 
    Given I double `aws --output json route53 list-hosted-zones` with "AWS Hosted Zone JSON Output" 
    When I run `bundle exec zaws hosted_zone view --viewtype json`
    Then the stdout should contain "AWS Hosted Zone JSON Output\n" 

