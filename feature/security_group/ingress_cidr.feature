Feature: Security Group 
  Security Group(s) are viewable

   Scenario: Delete a vpc security group ingress cidr rule, but skip it cause it does not exist
    Given I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter  'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=target_group_name'` with stdout:
     """
	 {	"SecurityGroups": [ { "GroupName": "target_group_name","GroupId": "X_target_group_name" } ] }
     """
    And I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=group-id,Values=X_target_group_name' 'Name=ip-permission.cidr,Values=0.0.0.0/0' 'Name=ip-permission.protocol,Values=tcp' 'Name=ip-permission.to-port,Values=443'` with stdout:
     """
      {	"SecurityGroups": [] }
     """
    When I run `bundle exec zaws security_group delete_ingress_cidr target_group_name 0.0.0.0/0 tcp 443 --region us-west-1 --vpcid my_vpc_id`
    Then the output should contain "Security group ingress cidr rule does not exist. Skipping deletion.\n" 

   Scenario: Delete a vpc security group ingress cidr rule
    Given I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter  'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=target_group_name'` with stdout:
     """
	 {	"SecurityGroups": [ { "GroupName": "target_group_name","GroupId": "X_target_group_name" } ] }
     """
    And I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=group-id,Values=X_target_group_name' 'Name=ip-permission.cidr,Values=0.0.0.0/0' 'Name=ip-permission.protocol,Values=tcp' 'Name=ip-permission.to-port,Values=443'` with stdout:
     """
	 {	"SecurityGroups": [ { 
	        "GroupName": "target_group_name",
			"GroupId": "X_target_group_name",
			"IpPermissions": [ {
				  "ToPort": 443,
				  "IpProtocol": "tcp",
				  "IpRanges": [ { "CidrIp" : "0.0.0.0/0" } ],
				  "UserIdGroupPairs": [ ],
			      "FromPort": 443 } ] } ] }
    """
    And I double `aws --region us-west-1 ec2 revoke-security-group-ingress --group-id X_target_group_name --cidr 0.0.0.0/0 --protocol tcp --port 443` with stdout:
     """
       { "return": "true" }         
     """
    When I run `bundle exec zaws security_group delete_ingress_cidr target_group_name 0.0.0.0/0 tcp 443 --region us-west-1 --vpcid my_vpc_id`
    Then the output should contain "Security group ingress cidr rule deleted.\n" 


