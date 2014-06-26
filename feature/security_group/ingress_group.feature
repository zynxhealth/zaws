Feature: Security Group 
  Security Group(s) are viewable
    
   Scenario: Determine a vpc securiry group ingress group rule identified by source and target has NOT been created
	Given I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter  'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=target_group_name'` with stdout:
     """
	 {	"SecurityGroups": [ { "GroupName": "target_group_name","GroupId": "X_target_group_name" } ] }
     """
	And I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter  'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=source_group_name'` with stdout:
     """
	 {	"SecurityGroups": [ { "GroupName": "source_group_name","GroupId": "X_source_group_name" } ] }
     """
    And I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=group-id,Values=X_target_group_name' 'Name=ip-permission.group-id,Values=X_source_group_name' 'Name=ip-permission.protocol,Values=tcp' 'Name=ip-permission.to-port,Values=443'` with stdout:
     """
      {	"SecurityGroups": [] }
     """
    When I run `bundle exec zaws security_group ingress_group_exists target_group_name source_group_name tcp 443 --region us-west-1 --vpcid my_vpc_id`
    Then the output should contain "false\n" 

   Scenario: Determine a vpc security group ingress group rule identified by source and target has been created
	Given I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter  'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=target_group_name'` with stdout:
     """
	 {	"SecurityGroups": [ { "GroupName": "target_group_name","GroupId": "X_target_group_name" } ] }
     """
	And I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter  'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=source_group_name'` with stdout:
     """
	 {	"SecurityGroups": [ { "GroupName": "source_group_name","GroupId": "X_source_group_name" } ] }
     """
    And I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=group-id,Values=X_target_group_name' 'Name=ip-permission.group-id,Values=X_source_group_name' 'Name=ip-permission.protocol,Values=tcp' 'Name=ip-permission.to-port,Values=443'` with stdout:
     """
	 {	"SecurityGroups": [ { 
	        "GroupName": "target_group_name",
			"GroupId": "X_target_group_name",
			"IpPermissions": [ {
				  "ToPort": 443,
				  "IpProtocol": "tcp",
				  "IpRanges": [],
				  "UserIdGroupPairs": [ {
					 "UserId": "958601521864",
					 "GroupId": "X_source_group_name" } ],
			      "FromPort": 443 } ] } ] }
     """
    When I run `bundle exec zaws security_group ingress_group_exists target_group_name source_group_name tcp 443 --region us-west-1 --vpcid my_vpc_id`
    Then the output should contain "true\n" 

   Scenario: Declare a new vpc security group ingress group rule identified by source and target. Create it cause it doesn't exist. Also, should append the command to remove the security group to file.
    Given I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter  'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=target_group_name'` with stdout:
     """
	 {	"SecurityGroups": [ { "GroupName": "target_group_name","GroupId": "X_target_group_name" } ] }
     """
	And I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter  'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=source_group_name'` with stdout:
     """
	 {	"SecurityGroups": [ { "GroupName": "source_group_name","GroupId": "X_source_group_name" } ] }
	 """
    And I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=group-id,Values=X_target_group_name' 'Name=ip-permission.group-id,Values=X_source_group_name' 'Name=ip-permission.protocol,Values=tcp' 'Name=ip-permission.to-port,Values=443'` with stdout:
     """
      {	"SecurityGroups": [] }
     """
    And I double `aws --region us-west-1 ec2 authorize-security-group-ingress --group-id X_target_group_name --source-security-group-owner-id X_source_group_name --protocol tcp --port 443` with stdout:
     """
      {	"return": "true" }
     """
    When I run `bundle exec zaws security_group declare_ingress_group target_group_name source_group_name tcp 443 --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "Ingress group rule created.\n"

   Scenario: Declare a new vpc security group ingress group rule identified by source and target. Do not create it because it does exist.
    Given I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter  'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=target_group_name'` with stdout:
     """
	 {	"SecurityGroups": [ { "GroupName": "target_group_name","GroupId": "X_target_group_name" } ] }
     """
	And I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter  'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=source_group_name'` with stdout:
     """
	 {	"SecurityGroups": [ { "GroupName": "source_group_name","GroupId": "X_source_group_name" } ] }
	 """
    And I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=group-id,Values=X_target_group_name' 'Name=ip-permission.group-id,Values=X_source_group_name' 'Name=ip-permission.protocol,Values=tcp' 'Name=ip-permission.to-port,Values=443'` with stdout:
     """
	 {	"SecurityGroups": [ { 
	        "GroupName": "target_group_name",
			"GroupId": "X_target_group_name",
			"IpPermissions": [ {
				  "ToPort": 443,
				  "IpProtocol": "tcp",
				  "IpRanges": [],
				  "UserIdGroupPairs": [ {
					 "UserId": "958601521864",
					 "GroupId": "X_source_group_name" } ],
			      "FromPort": 443 } ] } ] }
     """
    Given an empty file named "undo.sh.1" 
    When I run `bundle exec zaws security_group declare_ingress_group target_group_name source_group_name tcp 443 --region us-west-1 --vpcid my_vpc_id --undofile undo.sh.1`
	Then the output should contain "Ingress group rule not created. Exists already.\n"
    And the file "undo.sh.1" should contain "zaws security_group delete_ingress_group target_group_name source_group_name tcp 443 --region us-west-1 --vpcid my_vpc_id $XTRA_OPTS"

   Scenario: Perform a nagios check, with the result indicatin OK (exit 0), indicating declaring a vpc security group ingress group requires no action because it exists.
    Given I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter  'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=target_group_name'` with stdout:
     """
	 {	"SecurityGroups": [ { "GroupName": "target_group_name","GroupId": "X_target_group_name" } ] }
     """
	And I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter  'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=source_group_name'` with stdout:
     """
	 {	"SecurityGroups": [ { "GroupName": "source_group_name","GroupId": "X_source_group_name" } ] }
	 """
    And I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=group-id,Values=X_target_group_name' 'Name=ip-permission.group-id,Values=X_source_group_name' 'Name=ip-permission.protocol,Values=tcp' 'Name=ip-permission.to-port,Values=443'` with stdout:
     """
	 {	"SecurityGroups": [ { 
	        "GroupName": "target_group_name",
			"GroupId": "X_target_group_name",
			"IpPermissions": [ {
				  "ToPort": 443,
				  "IpProtocol": "tcp",
				  "IpRanges": [],
				  "UserIdGroupPairs": [ {
					 "UserId": "958601521864",
					 "GroupId": "X_source_group_name" } ],
			      "FromPort": 443 } ] } ] }
     """
    When I run `bundle exec zaws security_group declare_ingress_group target_group_name source_group_name tcp 443 --region us-west-1 --vpcid my_vpc_id --nagios`
	Then the output should contain "OK: Security group ingress group rule exists.\n"
    And the exit status should be 0
		
   Scenario: Perform a nagios check, with the result indicatin CRITICAL (exit 2), indicating declaring a security group ingress group requires action because it does not exist.
    Given I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter  'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=target_group_name'` with stdout:
     """
	 {	"SecurityGroups": [ { "GroupName": "target_group_name","GroupId": "X_target_group_name" } ] }
     """
	And I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter  'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=source_group_name'` with stdout:
     """
	 {	"SecurityGroups": [ { "GroupName": "source_group_name","GroupId": "X_source_group_name" } ] }
	 """
    And I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=group-id,Values=X_target_group_name' 'Name=ip-permission.group-id,Values=X_source_group_name' 'Name=ip-permission.protocol,Values=tcp' 'Name=ip-permission.to-port,Values=443'` with stdout:
     """
      {	"SecurityGroups": [] }
     """
    When I run `bundle exec zaws security_group declare_ingress_group target_group_name source_group_name tcp 443 --region us-west-1 --vpcid my_vpc_id --nagios`
	Then the output should contain "CRITICAL: Security group ingress group rule does not exist.\n"
    And the exit status should be 2

   Scenario: Delete a vpc security group ingress group rule, but skip it cause it does not exist
    Given I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter  'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=target_group_name'` with stdout:
     """
	 {	"SecurityGroups": [ { "GroupName": "target_group_name","GroupId": "X_target_group_name" } ] }
     """
	And I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter  'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=source_group_name'` with stdout:
     """
	 {	"SecurityGroups": [ { "GroupName": "source_group_name","GroupId": "X_source_group_name" } ] }
	 """
    And I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=group-id,Values=X_target_group_name' 'Name=ip-permission.group-id,Values=X_source_group_name' 'Name=ip-permission.protocol,Values=tcp' 'Name=ip-permission.to-port,Values=443'` with stdout:
     """
      {	"SecurityGroups": [] }
     """
    When I run `bundle exec zaws security_group delete_ingress_group target_group_name source_group_name tcp 443 --region us-west-1 --vpcid my_vpc_id`
    Then the output should contain "Security group ingress group rule does not exist. Skipping deletion.\n" 

   Scenario: Delete a vpc security group ingress group rule
    Given I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter  'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=target_group_name'` with stdout:
     """
	 {	"SecurityGroups": [ { "GroupName": "target_group_name","GroupId": "X_target_group_name" } ] }
     """
	And I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter  'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=source_group_name'` with stdout:
     """
	 {	"SecurityGroups": [ { "GroupName": "source_group_name","GroupId": "X_source_group_name" } ] }
	 """
    And I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=group-id,Values=X_target_group_name' 'Name=ip-permission.group-id,Values=X_source_group_name' 'Name=ip-permission.protocol,Values=tcp' 'Name=ip-permission.to-port,Values=443'` with stdout:
     """
	 {	"SecurityGroups": [ { 
	        "GroupName": "target_group_name",
			"GroupId": "X_target_group_name",
			"IpPermissions": [ {
				  "ToPort": 443,
				  "IpProtocol": "tcp",
				  "IpRanges": [],
				  "UserIdGroupPairs": [ {
					 "UserId": "958601521864",
					 "GroupId": "X_source_group_name" } ],
			      "FromPort": 443 } ] } ] }
     """
    And I double `aws --region us-west-1 ec2 revoke-security-group-ingress --group-id X_target_group_name --source-security-group-owner-id X_source_group_name --protocol tcp --port 443` with stdout:
     """
       { "return": "true" }         
     """
    When I run `bundle exec zaws security_group delete_ingress_group target_group_name source_group_name tcp 443 --region us-west-1 --vpcid my_vpc_id`
    Then the output should contain "Security group ingress group rule deleted.\n" 


