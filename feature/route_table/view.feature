Feature: Route Table 
  Route Tables control network traffic in AWS between subnets and gateways. 
    
  Scenario: Get route table in a human readable table. 
    Given I double `aws --output table --region us-west-1 ec2 describe-route-tables` with "AWS Route Table Output" 
    When I run `bundle exec zaws route_table view --region us-west-1 --viewtype table`
    Then the stdout should contain "AWS Route Table Output\n" 

  Scenario: Get route table in a human readable table form by default 
    Given I double `aws --output table --region us-west-1 ec2 describe-route-tables` with "AWS Route Table Output" 
    When I run `bundle exec zaws route_table view --region us-west-1`
    Then the stdout should contain "AWS Route Table Output\n" 

  Scenario: Get route table in JSON form 
    Given I double `aws --output json --region us-west-1 ec2 describe-route-tables` with "AWS Route Table JSON Output" 
    When I run `bundle exec zaws route_table view --region us-west-1 --viewtype json`
    Then the stdout should contain "AWS Route Table JSON Output\n" 

  Scenario: Get route table from specified vpcid
    Given I double `aws --output table --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id'` with "AWS Route Table Output" 
    When I run `bundle exec zaws route_table view --region us-west-1 --vpcid my_vpc_id`
    Then the stdout should contain "AWS Route Table Output\n" 
	  


