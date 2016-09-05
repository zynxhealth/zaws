Feature: Route Table 

  Scenario: Determine that a subnet is associated to a route table 
	Given I double `aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=cidr,Values=my_cidr_block'` with stdout: 
     """
		{ "Subnets": [ { "SubnetId" : "X" } ] }
     """
    And I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX","Associations": [ { "SubnetId":"X" } ] } ] }
     """
    When I run `bundle exec zaws route_table subnet_assoc_exists my_route_table my_cidr_block --region us-west-1 --vpcid my_vpc_id`
    Then the output should contain "true\n" 
 
  Scenario: Determine that a subnet is NOT associated to a route table 
 	Given I double `aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=cidr,Values=my_cidr_block'` with stdout: 
     """
		{ "Subnets": [ { "SubnetId" : "X" } ] }
     """
    And I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX","Associations": [ ] } ] }
     """
    When I run `bundle exec zaws route_table subnet_assoc_exists my_route_table my_cidr_block --region us-west-1 --vpcid my_vpc_id`
    Then the output should contain "false\n" 

  Scenario: Associate a subnet to a route table
 	Given I double `aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=cidr,Values=my_cidr_block'` with stdout: 
     """
		{ "Subnets": [ { "SubnetId" : "X" } ] }
     """
    And I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX","Associations": [ ] } ] }
     """
    And I double `aws --region us-west-1 ec2 associate-route-table --subnet-id X --route-table-id rtb-XXXXXXX` with stdout:
     """
	 {	"AssociationId": "rtbassoc-???????" }
     """
    When I run `bundle exec zaws route_table assoc_subnet my_route_table my_cidr_block --region us-west-1 --vpcid my_vpc_id`
    Then the output should contain "Route table associated to subnet.\n" 

  Scenario: Associate a subnet to a route table, skip because it exists already
  	Given I double `aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=cidr,Values=my_cidr_block'` with stdout: 
     """
		{ "Subnets": [ { "SubnetId" : "X" } ] }
     """
    And I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX","Associations": [ { "SubnetId":"X" } ] } ] }
     """
    When I run `bundle exec zaws route_table assoc_subnet my_route_table my_cidr_block --region us-west-1 --vpcid my_vpc_id`
    Then the output should contain "Route table already associated to subnet. Skipping association.\n" 
   
  Scenario: Delete subnet association to route table
    Given I double `aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=cidr,Values=my_cidr_block'` with stdout: 
     """
		{ "Subnets": [ { "SubnetId" : "X" } ] }
     """
    And I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX","Associations": [ { "SubnetId":"X","RouteTableAssociationId":"rtbassoc-????????" } ] } ] }
     """
    And I double `aws --region us-west-1 ec2 disassociate-route-table --association-id rtbassoc-????????` with stdout:
     """
	 {	"return" : "true" }
     """
    When I run `bundle exec zaws route_table delete_assoc_subnet my_route_table my_cidr_block --region us-west-1 --vpcid my_vpc_id`
    Then the output should contain "Route table association to subnet deleted.\n" 
 
  Scenario: Delete subnet association to route table that does not exists, skip it.
	Given I double `aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=cidr,Values=my_cidr_block'` with stdout: 
     """
		{ "Subnets": [ { "SubnetId" : "X" } ] }
     """
    And I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX","Associations": [ ] } ] }
     """
    When I run `bundle exec zaws route_table delete_assoc_subnet my_route_table my_cidr_block --region us-west-1 --vpcid my_vpc_id`
    Then the output should contain "Route table association to subnet not deleted because it does not exist.\n" 
		
  Scenario: Nagios OK
  	Given I double `aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=cidr,Values=my_cidr_block'` with stdout: 
     """
		{ "Subnets": [ { "SubnetId" : "X" } ] }
     """
    And I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX","Associations": [ { "SubnetId":"X" } ] } ] }
     """
    When I run `bundle exec zaws route_table assoc_subnet my_route_table my_cidr_block --region us-west-1 --vpcid my_vpc_id --nagios`
 	Then the output should contain "OK: Route table association to subnet exists.\n"
    And the exit status should be 0
	
  Scenario: Nagios CRITICAL
 	Given I double `aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=cidr,Values=my_cidr_block'` with stdout: 
     """
		{ "Subnets": [ { "SubnetId" : "X" } ] }
     """
    And I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX","Associations": [ ] } ] }
     """
    When I run `bundle exec zaws route_table assoc_subnet my_route_table my_cidr_block --region us-west-1 --vpcid my_vpc_id --nagios`
    Then the output should contain "CRITICAL: Route table association to subnet does not exist.\n"
    And the exit status should be 2
 
  Scenario: Undo file
 	Given I double `aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=cidr,Values=my_cidr_block'` with stdout: 
     """
		{ "Subnets": [ { "SubnetId" : "X" } ] }
     """
    And I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX","Associations": [ ] } ] }
     """
    And I double `aws --region us-west-1 ec2 associate-route-table --subnet-id X --route-table-id rtb-XXXXXXX` with stdout:
     """
	 {	"AssociationId": "rtbassoc-???????" }
     """
    Given an empty file named "undo.sh.1"
    When I run `bundle exec zaws route_table assoc_subnet my_route_table my_cidr_block --region us-west-1 --vpcid my_vpc_id --undofile undo.sh.1`
    Then the output should contain "Route table associated to subnet.\n" 
	And the file "undo.sh.1" should contain "zaws route_table delete_assoc_subnet my_route_table my_cidr_block --region us-west-1 --vpcid my_vpc_id"



