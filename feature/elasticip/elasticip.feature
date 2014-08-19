Feature: Elasticip 
    
  Scenario: Determine elasticip exists for instance 
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-abc1234","Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
	And I double `aws --output json --region us-west-1 ec2 describe-addresses --filter 'Name=domain,Values=vpc' 'Name=instance-id,Values=i-abc1234'` with stdout:
     """
	 {  "Addresses": [ { "InstanceId" : "i-abc1234", "PublicIp": "198.51.100.0", "Domain": "vpc", "AssociationId":"eipassoc-abcd1234", "AllocationId":"eipalloc-abcd1234"} ] }
	 """
    When I run `bundle exec zaws elasticip assoc_exists my_instance --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "true\n" 

  Scenario: Determine elasticip DOES NOT exist for instance 
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-abc1234","Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
	And I double `aws --output json --region us-west-1 ec2 describe-addresses --filter 'Name=domain,Values=vpc' 'Name=instance-id,Values=i-abc1234'` with stdout:
     """
	 {  "Addresses": [ ] }
	 """
    When I run `bundle exec zaws elasticip assoc_exists my_instance --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "false\n" 

  Scenario: Declare elasticip for an instance by external id
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-abc1234","Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
	And I double `aws --output json --region us-west-1 ec2 describe-addresses --filter 'Name=domain,Values=vpc' 'Name=instance-id,Values=i-abc1234'` with stdout:
     """
	 {  "Addresses": [ ] }
	 """
	And I double `aws --region us-west-1 ec2 allocate-address --domain vpc` with stdout:
     """
	 {  "PublicIp": "198.51.100.0", "Domain": "vpc", "AllocationId": "eipalloc-abcd1234",  "AllocationId":"eipalloc-abcd1234" }
	 """
	 And I double `aws --region us-west-1 ec2 associate-address --instance-id i-abc1234 --allocation-id eipalloc-abcd1234` with stdout:
     """
	 {  "return": "true" }
	 """
    When I run `bundle exec zaws elasticip declare my_instance --region us-west-1 --vpcid my_vpc_id --verbose`
	Then the output should contain "New elastic ip associated to instance.\n" 

  Scenario: Declare elasticip for an instance by external id, Skip creation
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-abc1234","Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
	And I double `aws --output json --region us-west-1 ec2 describe-addresses --filter 'Name=domain,Values=vpc' 'Name=instance-id,Values=i-abc1234'` with stdout:
     """
	 {  "Addresses": [ { "InstanceId" : "i-abc1234", "PublicIp": "198.51.100.0", "Domain": "vpc", "AssociationId":"eipassoc-abcd1234", "AllocationId":"eipalloc-abcd1234"} ] }
	 """
    When I run `bundle exec zaws elasticip declare my_instance --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "instance already has an elastic ip. Skipping creation.\n" 

  Scenario: Delete
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-abc1234","Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
	And I double `aws --output json --region us-west-1 ec2 describe-addresses --filter 'Name=domain,Values=vpc' 'Name=instance-id,Values=i-abc1234'` with stdout:
     """
	 {  "Addresses": [ { "InstanceId" : "i-abc1234", "PublicIp": "198.51.100.0", "Domain": "vpc", "AssociationId":"eipassoc-abcd1234", "AllocationId":"eipalloc-abcd1234"} ] }
	 """
    And I double `aws --region us-west-1 ec2 disassociate-address --association-id eipassoc-abcd1234` with stdout:
     """
	 {  "return": "true" }
	 """
    And I double `aws --region us-west-1 ec2 release-address --allocation-id eipalloc-abcd1234` with stdout:
     """
	 {  "return": "true" }
	 """
    When I run `bundle exec zaws elasticip release my_instance --region us-west-1 --vpcid my_vpc_id --verbose`
	Then the output should contain "Deleted elasticip.\n" 

  Scenario: Delete, skip
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-abc1234","Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
	And I double `aws --output json --region us-west-1 ec2 describe-addresses --filter 'Name=domain,Values=vpc' 'Name=instance-id,Values=i-abc1234'` with stdout:
     """
	 {  "Addresses": [ ] }
	 """
    When I run `bundle exec zaws elasticip release my_instance --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "Elasticip does not exist. Skipping deletion.\n" 

  Scenario: Nagios OK
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-abc1234","Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
	And I double `aws --output json --region us-west-1 ec2 describe-addresses --filter 'Name=domain,Values=vpc' 'Name=instance-id,Values=i-abc1234'` with stdout:
     """
	 {  "Addresses": [ { "InstanceId" : "i-abc1234", "PublicIp": "198.51.100.0", "Domain": "vpc", "AssociationId":"eipassoc-abcd1234", "AllocationId":"eipalloc-abcd1234"} ] }
	 """
    When I run `bundle exec zaws elasticip declare my_instance --region us-west-1 --vpcid my_vpc_id --nagios`
	Then the output should contain "OK: Elastic Ip exists.\n" 

  Scenario: Nagios CRITICAL
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-abc1234","Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
	And I double `aws --output json --region us-west-1 ec2 describe-addresses --filter 'Name=domain,Values=vpc' 'Name=instance-id,Values=i-abc1234'` with stdout:
     """
	 {  "Addresses": [ ] }
	 """
    When I run `bundle exec zaws elasticip declare my_instance --region us-west-1 --vpcid my_vpc_id --nagios`
	Then the output should contain "CRITICAL: Elastic Ip DOES NOT EXIST.\n" 

  Scenario: Undo file
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-abc1234","Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
	And I double `aws --output json --region us-west-1 ec2 describe-addresses --filter 'Name=domain,Values=vpc' 'Name=instance-id,Values=i-abc1234'` with stdout:
     """
	 {  "Addresses": [ ] }
	 """
	And I double `aws --region us-west-1 ec2 allocate-address --domain vpc` with stdout:
     """
	 {  "PublicIp": "198.51.100.0", "Domain": "vpc", "AllocationId": "eipalloc-abcd1234", "AllocationId":"eipalloc-abcd1234" }
	 """
	And I double `aws --region us-west-1 ec2 associate-address --instance-id i-abc1234 --allocation-id eipalloc-abcd1234` with stdout:
     """
	 {  "return": "true" }
	 """
    Given an empty file named "undo.sh.1" 
	When I run `bundle exec zaws elasticip declare my_instance --region us-west-1 --vpcid my_vpc_id --undofile undo.sh.1 --verbose`
	Then the output should contain "New elastic ip associated to instance.\n" 
	And the file "undo.sh.1" should contain "zaws elasticip release my_instance --region us-west-1 --vpcid my_vpc_id $XTRA_OPTS"

   

