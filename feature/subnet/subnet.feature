Feature: Subnet
  Subnets should be createable once in a specific availability zone.
	 
  Scenario: Determine a subnet has NOT been created in vpc
    Given I double `aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=cidr,Values=my_cidr_block'` with stdout:
     """
      {	"Subnets": [] }
     """
    When I run `bundle exec zaws subnet exists --region us-west-1 --cidrblock my_cidr_block --vpcid my_vpc_id`
    Then the output should contain "false\n" 

  Scenario: Determine a subnet has been created in vpc
    Given I double `aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=cidr,Values=my_cidr_block'` with stdout: 
     """
		{ "Subnets": [ { "SubnetId" : "X" } ] }
     """
    When I run `bundle exec zaws subnet exists --region us-west-1 --cidrblock my_cidr_block --vpcid my_vpc_id`
    Then the output should contain "true\n" 

  Scenario: Declare a subnet but do not create it if it exists
    Given I double `aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=cidr,Values=my_cidr_block'` with stdout: 
     """
		{ "Subnets": [ { "SubnetId" : "X" } ] }
     """
    When I run `bundle exec zaws subnet declare --region us-west-1 --cidrblock my_cidr_block --vpcid my_vpc_id --availabilityzone us-west-1a`
    Then the output should contain "No action needed. Subnet exists already.\n" 

  Scenario: Declare a subnet and create it 
    Given I double `aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=cidr,Values=my_cidr_block'` with stdout: 
     """
		{ "Subnets": [] }
     """
    And I double `aws --output json --region us-west-1 ec2 create-subnet --vpc-id my_vpc_id --cidr-block my_cidr_block --availability-zone us-west-1a` with stdout:
     """
       { "Subnet": { "State": "available" } }        
     """
    When I run `bundle exec zaws subnet declare --region us-west-1 --cidrblock my_cidr_block --vpcid my_vpc_id --availabilityzone us-west-1a`
    Then the output should contain "Subnet created.\n" 

   Scenario: Delete a subnet, but skip it cause it does not exist
    Given I double `aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=cidr,Values=my_cidr_block'` with stdout: 
     """
		{ "Subnets": [] }
     """
    When I run `bundle exec zaws subnet delete  --region us-west-1 --cidrblock my_cidr_block --vpcid my_vpc_id`
    Then the output should contain "Subnet does not exist. Skipping deletion.\n" 

   Scenario: Delete a subnet
    Given I double `aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=cidr,Values=my_cidr_block'` with stdout: 
     """
		{ "Subnets": [ { "SubnetId" : "X" } ] }
     """
    And I double `aws --region us-west-1 ec2 delete-subnet --subnet-id X` with stdout:
     """
       { "return": "true" }         
     """
    When I run `bundle exec zaws subnet delete --region us-west-1 --cidrblock my_cidr_block --vpcid my_vpc_id`
    Then the output should contain "Subnet deleted.\n" 

   Scenario: Perform a nagios check, with the result indicatin OK (exit 0), indicating declaring a subnet requires no action because it exists.
    Given I double `aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=cidr,Values=my_cidr_block'` with stdout: 
     """
		{ "Subnets": [ { "SubnetId" : "X" } ] }
     """
    When I run `bundle exec zaws subnet declare --region us-west-1 --cidrblock my_cidr_block --vpcid my_vpc_id --availabilityzone us-west-1a --nagios`
	Then the output should contain "OK: Subnet Exists.\n"
    And the exit status should be 0
		
   Scenario: Perform a nagios check, with the result indicatin CRITICAL (exit 2), indicating declaring a subnet requires action because it does not exist.
    Given I double `aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=cidr,Values=my_cidr_block'` with stdout: 
     """
		{ "Subnets": [] }
     """
    When I run `bundle exec zaws subnet declare --region us-west-1 --cidrblock my_cidr_block --vpcid my_vpc_id --availabilityzone us-west-1a --nagios`
	Then the output should contain "CRITICAL: Subnet Does Not Exist.\n"
    And the exit status should be 2

   Scenario: Declaring a subnet, should append the command to remove the subnet to file.
    Given I double `aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=cidr,Values=my_cidr_block'` with stdout: 
     """
		{ "Subnets": [] }
     """
    And I double `aws --output json --region us-west-1 ec2 create-subnet --vpc-id my_vpc_id --cidr-block my_cidr_block --availability-zone us-west-1a` with stdout:
     """
       { "Subnet": { "State": "available" } }        
     """
	Given an empty file named "undo.sh.1" 
    When I run `bundle exec zaws subnet declare --region us-west-1 --cidrblock my_cidr_block --vpcid my_vpc_id --availabilityzone us-west-1a --undofile undo.sh.1`
    Then the output should contain "Subnet created.\n" 
	And the file "undo.sh.1" should contain "zaws subnet delete --region us-west-1 --cidrblock my_cidr_block --vpcid my_vpc_id $XTRA_OPTS"


