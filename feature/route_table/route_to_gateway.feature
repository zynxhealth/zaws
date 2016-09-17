Feature: Route to Gateway

  Scenario: Declare route to gateway id  
	Given I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX", "Routes":[ {"DestinationCidrBlock": "0.0.0.0/0", "GatewayId": "igw-YYYYYYY"} ] } ] }
     """
    And I double `aws --region us-west-1 ec2 create-route --route-table-id rtb-XXXXXXX --destination-cidr-block 0.0.0.0/0 --gateway-id igw-XXXXXXX` with stdout:
     """
	 {	"return" : "true" }
     """
    When I run `bundle exec zaws route_table declare_route_to_gateway my_route_table 0.0.0.0/0 igw-XXXXXXX --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "Route created to gateway.\n" 

  Scenario: Declare route to gateway id, but skip it because it exists
	Given I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX", "Routes":[ {"DestinationCidrBlock": "0.0.0.0/0", "GatewayId": "igw-XXXXXXX"} ] } ] }
     """
    When I run `bundle exec zaws route_table declare_route_to_gateway my_route_table 0.0.0.0/0 igw-XXXXXXX --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "Route to gateway exists. Skipping creation.\n" 
   
  Scenario: Undo file
    Given I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX", "Routes":[ {"DestinationCidrBlock": "0.0.0.0/0", "GatewayId": "igw-XXXXXXX"} ] } ] }
     """
    Given an empty file named "undo.sh.1" 
    When I run `bundle exec zaws route_table declare_route_to_gateway my_route_table 0.0.0.0/0 igw-XXXXXXX --region us-west-1 --vpcid my_vpc_id --undofile undo.sh.1`
	Then the output should contain "Route to gateway exists. Skipping creation.\n" 
	And the file "undo.sh.1" should contain "zaws route_table delete_route my_route_table 0.0.0.0/0 --region us-west-1 --vpcid my_vpc_id $XTRA_OPTS"
   

  #Deletion and Undo file covered by route_to_instance.feature because deletion requires route table and cidrblock only.

