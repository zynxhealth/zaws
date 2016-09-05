Feature: Load Balancer 
    
  Scenario: Get load balancer in a human readable table. 
    Given I double `aws --output table --region us-west-1 elb describe-load-balancers` with "AWS Load Balancer Output" 
    When I run `bundle exec zaws load_balancer view --region us-west-1 --viewtype table`
    Then the stdout should contain "AWS Load Balancer Output\n" 

  Scenario: Get load balancer in a human readable table form by default 
    Given I double `aws --output table --region us-west-1 elb describe-load-balancers` with "AWS Load Balancer Output" 
    When I run `bundle exec zaws load_balancer view --region us-west-1`
    Then the stdout should contain "AWS Load Balancer Output\n" 

  Scenario: Get load balancer in JSON form 
    Given I double `aws --output json --region us-west-1 elb describe-load-balancers` with "AWS Load Balancer JSON Output" 
    When I run `bundle exec zaws load_balancer view --region us-west-1 --viewtype json`
    Then the stdout should contain "AWS Load Balancer JSON Output\n" 


