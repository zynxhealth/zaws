Feature: Associate Security Group 
    
  Scenario: Determine a security group is associated to instance by external id
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-XXXXXXX","Tags": [ { "Value": "my_instance","Key": "externalid" } ], "SecurityGroups" : [ { "GroupName": "my_security_group", "GroupId":"sg-X" } ] } ] } ] } 
	 """
    And I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=my_security_group'` with stdout:
     """
	 {	"SecurityGroups": [ { "GroupName": "my_security_group","GroupId":"sg-X" } ] }
     """
    When I run `zaws compute exists_security_group_assoc my_instance my_security_group --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "true\n" 
	 
  Scenario: Determine a security group is not associated to instance by external id
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-XXXXXXX","Tags": [ { "Value": "my_instance","Key": "externalid" } ], "SecurityGroups" : [ { "GroupName": "my_security_group", "GroupId":"sg-X" } ] } ] } ] } 
	 """
    And I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=my_security_group'` with stdout:
     """
	 {	"SecurityGroups": [ { "GroupName": "my_security_group","GroupId":"sg-Y" } ] }
     """
    When I run `zaws compute exists_security_group_assoc my_instance my_security_group --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "false\n" 
	
  Scenario: Change security group of instance by external id
	Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-XXXXXXX","Tags": [ { "Value": "my_instance","Key": "externalid" } ], "SecurityGroups" : [ { "GroupName": "my_security_group", "GroupId":"sg-X" } ] } ] } ] } 
	 """
    And I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=my_security_group'` with stdout:
     """
	 {	"SecurityGroups": [ { "GroupName": "my_security_group","GroupId":"sg-Y" } ] }
     """
	And I double `aws --region us-west-1 ec2 modify-instance-attribute --instance-id i-XXXXXXX --groups sg-Y ` with stdout:
     """
	 {  "return": "true" }
	 """
    When I run `zaws compute assoc_security_group my_instance my_security_group --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "Security Group Association Changed.\n" 
	  
  Scenario: Not Change security group of instance by external id, but it is already associated
	Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-XXXXXXX","Tags": [ { "Value": "my_instance","Key": "externalid" } ], "SecurityGroups" : [ { "GroupName": "my_security_group", "GroupId":"sg-X" } ] } ] } ] } 
	 """
    And I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=my_security_group'` with stdout:
     """
	 {	"SecurityGroups": [ { "GroupName": "my_security_group","GroupId":"sg-X" } ] }
     """
    When I run `zaws compute assoc_security_group my_instance my_security_group --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "Security Group Association Not Changed.\n" 


