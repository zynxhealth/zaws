Feature: Route Table 
  Route Tables control network traffic in AWS between subnets and gateways. 
    
  Scenario: Determine a route table DOES NOT exists by external id
	Given I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
      {	"RouteTables": [] }
     """
    When I run `bundle exec zaws route_table exists_by_external_id my_route_table --region us-west-1 --vpcid my_vpc_id`
    Then the output should contain "false\n" 
  
  Scenario: Determine a route table exists by external id
	Given I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX" } ] }
     """
    When I run `bundle exec zaws route_table exists_by_external_id my_route_table --region us-west-1 --vpcid my_vpc_id`
    Then the output should contain "true\n" 
  
  Scenario: Declare route table by external id
	Given I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
      {	"RouteTables": [] }
     """
	And I double `aws --region us-west-1 ec2 create-route-table --vpc-id my_vpc_id` with stdout:
     """
      {	"RouteTable": { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX" } }
     """
    And I double `aws --region us-west-1 ec2 create-tags --resources rtb-XXXXXXX --tags Key=externalid,Value=my_route_table` with stdout:
     """
      {	"return": "true" }
     """
    When I run `bundle exec zaws route_table declare my_route_table my_vpc_id --region us-west-1`
	Then the output should contain "Route table created with external id: my_route_table.\n" 
 
  Scenario: Declare route table by external id, but DO NOT create it because it exists
	Given I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
      {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX" } ] }
     """
    When I run `bundle exec zaws route_table declare my_route_table my_vpc_id --region us-west-1`
	Then the output should contain "Route table exists already. Skipping Creation.\n" 

  Scenario: Delete a route table in a vpc, but skip it cause it does not exist
    Given I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
      {	"RouteTables": [] }
     """
    When I run `bundle exec zaws route_table delete my_route_table --region us-west-1 --vpcid my_vpc_id`
    Then the output should contain "Route table does not exist. Skipping deletion.\n" 

  Scenario: Delete a route table in a vpc
    Given I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
       { "RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX" } ] }
     """
    And I double `aws --region us-west-1 ec2 delete-route-table --route-table-id rtb-XXXXXXX` with stdout:
     """
       { "return": "true" }         
     """
    When I run `bundle exec zaws route_table delete my_route_table --region us-west-1 --vpcid my_vpc_id`
    Then the output should contain "Route table deleted.\n" 

   Scenario: Perform a nagios check, with the result indicatin OK (exit 0), indicating declaring a route table requires no action because it exists.
    Given I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
      {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX" } ] }
     """
    When I run `bundle exec zaws route_table declare my_route_table my_vpc_id --region us-west-1 --nagios`
	Then the output should contain "OK: Route table exists.\n"
    And the exit status should be 0
		
   Scenario: Perform a nagios check, with the result indicatin CRITICAL (exit 2), indicating declaring a security group requires action because it does not exist.
    Given I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
      {	"RouteTables": [ ] }
     """
    When I run `bundle exec zaws route_table declare my_route_table my_vpc_id --region us-west-1 --nagios`
	Then the output should contain "CRITICAL: Route table does not exist.\n"
    And the exit status should be 2

   Scenario: Declaring a route to an instance, should append the command to remove the security group to file.
    Given I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
      {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX" } ] }
     """
    Given an empty file named "undo.sh.1" 
    When I run `bundle exec zaws route_table declare my_route_table my_vpc_id --region us-west-1 --undofile undo.sh.1`
	Then the output should contain "Route table exists already. Skipping Creation.\n"
	And the file "undo.sh.1" should contain "zaws route_table delete my_route_table --region us-west-1 --vpcid my_vpc_id $XTRA_OPTS"

