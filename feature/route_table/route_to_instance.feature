Feature: Route Table 
  Route Tables control network traffic in AWS between subnets and gateways. 

   Scenario: Delete route 
	Given I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX", "Routes":[ {"DestinationCidrBlock": "0.0.0.0/0", "InstanceId": "i-XXXXXXX"} ] } ] }
     """
    And I double `aws --region us-west-1 ec2 delete-route --route-table-id rtb-XXXXXXX --destination-cidr-block 0.0.0.0/0` with stdout:
     """
	 {	"return" : "true" }
     """
    When I run `bundle exec zaws route_table delete_route my_route_table 0.0.0.0/0 --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "Route deleted.\n" 
	
   Scenario: Delete route skipped because it doesn't exist
	Given I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX", "Routes":[ {"DestinationCidrBlock": "1.1.1.1/0", "InstanceId": "i-XXXXXXX"} ] } ] }
     """
    When I run `bundle exec zaws route_table delete_route my_route_table 0.0.0.0/0 --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "Route does not exist. Skipping deletion.\n" 

