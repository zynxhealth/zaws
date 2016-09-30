Feature: Route to Gateway

  Scenario: Delete route propagation from gateway.
    Given I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-????????","PropagatingVgws" :  [ { "GatewayId":"vgw-????????" } ] } ] }
     """
	 And I double `aws --region us-west-1 ec2 disable-vgw-route-propagation --route-table-id rtb-???????? --gateway-id vgw-????????` with stdout:
     """
	 {	"return": "true" }
     """
    When I run `bundle exec zaws route_table delete_propagation_from_gateway my_route_table vgw-???????? --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "Deleted route propagation from gateway.\n" 

  Scenario: Delete route propagation from gateway, but skip it because it doesn't exist.
	Given I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-????????","PropagatingVgws" :  [ ] } ] }
     """
    When I run `bundle exec zaws route_table delete_propagation_from_gateway my_route_table vgw-???????? --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "Route propagation from gateway does not exist, skipping deletion.\n" 

  Scenario: Undo file
    Given I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-????????","PropagatingVgws" :  [] } ] }
     """
	And I double `aws --region us-west-1 ec2 enable-vgw-route-propagation --route-table-id rtb-???????? --gateway-id vgw-????????` with stdout:
     """
	 {	"return": "true" }
     """
    Given an empty file named "undo.sh.1"
    When I run `bundle exec zaws route_table declare_propagation_from_gateway my_route_table vgw-???????? --region us-west-1 --vpcid my_vpc_id --undofile undo.sh.1`
    Then the output should contain "Route propagation from gateway enabled.\n" 
	And the file "undo.sh.1" should contain "zaws route_table delete_propagation_from_gateway my_route_table vgw-???????? --region us-west-1 --vpcid my_vpc_id $XTRA_OPTS"

	


