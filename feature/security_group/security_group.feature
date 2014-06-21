Feature: Security Group 
  Security Group(s) are viewable
	 
   Scenario: Determine a security group identified by name and vpc has NOT been created
    Given I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=my_security_group_name'` with stdout:
     """
      {	"SecurityGroups": [] }
     """
    When I run `bundle exec zaws security_group exists_by_name my_security_group_name --region us-west-1 --vpcid my_vpc_id`
    Then the output should contain "false\n" 

   Scenario: Determine a security group identified by name and vpc has been created
    Given I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=my_security_group_name'` with stdout:
     """
      {	"SecurityGroups": [ { "GroupName": "my_security_group_name" } ] }
     """
    When I run `bundle exec zaws security_group exists_by_name my_security_group_name --region us-west-1 --vpcid my_vpc_id`
    Then the output should contain "true\n" 

   Scenario: Determine a security group identified by name has NOT been created
    Given I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter 'Name=group-name,Values=my_security_group_name'` with stdout:
     """
      {	"SecurityGroups": [] }
     """
    When I run `bundle exec zaws security_group exists_by_name my_security_group_name --region us-west-1`
    Then the output should contain "false\n" 

   Scenario: Determine a security group identified by name has been created
    Given I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter 'Name=group-name,Values=my_security_group_name'` with stdout:
     """
      {	"SecurityGroups": [ { "GroupName": "my_security_group_name" } ] }
     """
    When I run `bundle exec zaws security_group exists_by_name my_security_group_name --region us-west-1`
    Then the output should contain "true\n" 

   Scenario: Delete a security group in a vpc, but skip it cause it does not exist
    Given I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter  'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=my_security_group_name'` with stdout:
     """
      {	"SecurityGroups": [] }
     """
    When I run `bundle exec zaws security_group delete my_security_group_name --region us-west-1 --vpcid my_vpc_id`
    Then the output should contain "Security Group does not exist. Skipping deletion.\n" 

   Scenario: Delete a security group in a vpc
    Given I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter  'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=my_security_group_name'` with stdout:
     """
	 {	"SecurityGroups": [ { "GroupName": "my_security_group_name","GroupId": "sg-abcd1234" } ] }
     """
    And I double `aws --region us-west-1 ec2 delete-security-group --group-ids sg-abcd1234` with stdout:
     """
       { "return": "true" }         
     """
    When I run `bundle exec zaws security_group delete my_security_group_name --region us-west-1 --vpcid my_vpc_id`
    Then the output should contain "Security Group deleted.\n" 

   Scenario: Declare a new security group in vpc, but don't create it cause it exists
     Given I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter  'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=my_security_group_name'` with stdout:
      """
     {        "SecurityGroups": [ { "GroupName": "my_security_group_name" } ] }
      """
    When I run `bundle exec zaws security_group declare my_security_group_name 'My security gorup' --region us-west-1 --vpcid my_vpc_id`
    Then the output should contain "Security Group Exists Already. Skipping Creation.\n"

   Scenario: Declare a new security group in vpc
    Given I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter  'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=my_security_group_name'` with stdout:
      """
      {        "SecurityGroups": [] }
      """
    And I double `aws --output json --region us-west-1 ec2 create-security-group --vpc-id my_vpc_id --group-name my_security_group_name --description 'My security group'` with stdout:
      """
        { "return": "true" }
      """
    When I run `bundle exec zaws security_group declare my_security_group_name 'My security group' --region us-west-1 --vpcid my_vpc_id`
    Then the output should contain "Security Group Created.\n"

   Scenario: Perform a nagios check, with the result indicatin OK (exit 0), indicating declaring a security group requires no action because it exists.
	Given I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter  'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=my_security_group_name'` with stdout:
      """
     {        "SecurityGroups": [ { "GroupName": "my_security_group_name" } ] }
      """
    When I run `bundle exec zaws security_group declare my_security_group_name 'My security gorup' --region us-west-1 --vpcid my_vpc_id --nagios`
	Then the output should contain "OK: Security Group Exists.\n"
    And the exit status should be 0
		
   Scenario: Perform a nagios check, with the result indicatin CRITICAL (exit 2), indicating declaring a security group requires action because it does not exist.
     Given I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter  'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=my_security_group_name'` with stdout:
      """
      {        "SecurityGroups": [] }
      """
    When I run `bundle exec zaws security_group declare my_security_group_name 'My security group' --region us-west-1 --vpcid my_vpc_id --nagios`
	Then the output should contain "CRITICAL: Security Group Does Not Exist.\n"
    And the exit status should be 2

   Scenario: Declaring a security group, should append the command to remove the security group to file.
	Given I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter  'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=my_security_group_name'` with stdout:
      """
      {        "SecurityGroups": [] }
      """
    And I double `aws --output json --region us-west-1 ec2 create-security-group --vpc-id my_vpc_id --group-name my_security_group_name --description 'My security group'` with stdout:
      """
        { "return": "true" }
      """
	Given an empty file named "undo.sh.1" 
    When I run `bundle exec zaws security_group declare my_security_group_name 'My security group' --region us-west-1 --vpcid my_vpc_id --undofile undo.sh.1`
	Then the output should contain "Security Group Created.\n"
	And the file "undo.sh.1" should contain "zaws security_group delete my_security_group_name --region us-west-1 --vpcid my_vpc_id $XTRA_OPTS"

