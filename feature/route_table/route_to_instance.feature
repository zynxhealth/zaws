Feature: Route Table 
  Route Tables control network traffic in AWS between subnets and gateways. 
    
  Scenario: Determine a route DOES NOT exist to an instance by instance external id  
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-XXXXXXX","Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
	And I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX", "Routes":[ {"DestinationCidrBlock": "0.0.0.0/0", "InstanceId": "i-YYYYYYY"} ] } ] }
     """
    When I run `zaws route_table route_exists_by_instance my_route_table 0.0.0.0/0 my_instance --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "false\n" 
 
  Scenario: Determine a route exists to an instance by instance external id   
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-XXXXXXX","Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
	And I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX", "Routes":[ {"DestinationCidrBlock": "0.0.0.0/0", "InstanceId": "i-XXXXXXX"} ] } ] }
     """
    When I run `zaws route_table route_exists_by_instance my_route_table 0.0.0.0/0 my_instance --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "true\n" 
 
  Scenario: Declare route to an instance by instance external id
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-XXXXXXX","Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
	And I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX", "Routes":[ {"DestinationCidrBlock": "0.0.0.0/0", "InstanceId": "i-YYYYYYY"} ] } ] }
     """
    And I double `aws --region us-west-1 ec2 create-route --route-table-id rtb-XXXXXXX --destination-cidr-block 0.0.0.0/0 --instance-id i-XXXXXXX` with stdout:
     """
	 {	"return" : "true" }
     """
    When I run `zaws route_table declare_route my_route_table 0.0.0.0/0 my_instance --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "Route created to instance.\n" 

  Scenario: Declare route to an instance by instance external id, but skip createion because it exists.
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-XXXXXXX","Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
	And I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX", "Routes":[ {"DestinationCidrBlock": "0.0.0.0/0", "InstanceId": "i-XXXXXXX"} ] } ] }
     """
    When I run `zaws route_table declare_route my_route_table 0.0.0.0/0 my_instance --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "Route not created to instance. Skip creation.\n" 
		
   Scenario: Delete route 
	Given I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX", "Routes":[ {"DestinationCidrBlock": "0.0.0.0/0", "InstanceId": "i-XXXXXXX"} ] } ] }
     """
    And I double `aws --region us-west-1 ec2 delete-route --route-table-id rtb-XXXXXXX --destination-cidr-block 0.0.0.0/0` with stdout:
     """
	 {	"return" : "true" }
     """
    When I run `zaws route_table delete_route my_route_table 0.0.0.0/0 --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "Route deleted.\n" 
	
   Scenario: Delete route skipped because it doesn't exist
	Given I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX", "Routes":[ {"DestinationCidrBlock": "1.1.1.1/0", "InstanceId": "i-XXXXXXX"} ] } ] }
     """
    When I run `zaws route_table delete_route my_route_table 0.0.0.0/0 --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "Route does not exist. Skipping deletion.\n" 
	
   Scenario: Perform a nagios check, with the result indicatin OK (exit 0), indicating declaring a route requires no action because it exists.
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-XXXXXXX","Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
	And I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX", "Routes":[ {"DestinationCidrBlock": "0.0.0.0/0", "InstanceId": "i-XXXXXXX"} ] } ] }
     """
    When I run `zaws route_table declare_route my_route_table 0.0.0.0/0 my_instance --region us-west-1 --vpcid my_vpc_id --nagios`
	Then the output should contain "OK: Route to instance exists.\n"
    And the exit status should be 0
		
   Scenario: Perform a nagios check, with the result indicatin CRITICAL (exit 2), indicating declaring a security group requires action because it does not exist.
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-XXXXXXX","Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
	And I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX", "Routes":[ {"DestinationCidrBlock": "0.0.0.0/0", "InstanceId": "i-YYYYYYY"} ] } ] }
     """
    When I run `zaws route_table declare_route my_route_table 0.0.0.0/0 my_instance --region us-west-1 --vpcid my_vpc_id --nagios`
	Then the output should contain "CRITICAL: Route to instance does not exist.\n"
    And the exit status should be 2

   Scenario: Declaring a route to an instance, should append the command to remove the security group to file.
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-XXXXXXX","Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
	And I double `aws --output json --region us-west-1 ec2 describe-route-tables --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_route_table'` with stdout:
     """
	 {	"RouteTables": [ { "VpcId":"my_vpc_id","RouteTableId":"rtb-XXXXXXX", "Routes":[ {"DestinationCidrBlock": "0.0.0.0/0", "InstanceId": "i-XXXXXXX"} ] } ] }
     """
	Given an empty file named "undo.sh.1" 
    When I run `zaws route_table declare_route my_route_table 0.0.0.0/0 my_instance --region us-west-1 --vpcid my_vpc_id --undofile undo.sh.1`
	Then the output should contain "Route not created to instance. Skip creation.\n"
	And the file "undo.sh.1" should contain "zaws route_table delete_route my_route_table 0.0.0.0/0 --region us-west-1 --vpcid my_vpc_id $XTRA_OPTS"

