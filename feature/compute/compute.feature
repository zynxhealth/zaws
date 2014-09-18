Feature: Compute 
    
  Scenario: Determine a compute instance exists by instance external id  
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-XXXXXXX","Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
    When I run `bundle exec zaws compute exists_by_external_id my_instance --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "true\n" 
	  
  Scenario: Determine a compute instance DOES NOT exist by instance external id  
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [] } 
	 """
    When I run `bundle exec zaws compute exists_by_external_id my_instance --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "false\n" 

  Scenario: Declare a compute instance in vpc by external id, created undo file
	Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
    """
	  {  "Reservations": [] } 
	"""
	And I double `aws --output json --region us-west-1 ec2 describe-images --owner self --image-ids ami-abc123` with stdout:
	"""
      { "Images": [
		 { "RootDeviceName": "/dev/sda1", 
		   "BlockDeviceMappings": [
		    { "DeviceName": "/dev/sda1",
			  "Ebs": {
			    "DeleteOnTermination": true,
			    "SnapshotId": "snap-XXX",
				"VolumeSize": 7,
				"VolumeType": "standard" } } ] } ] }
    """
	And I double `aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=my_vpc_id'` with stdout:
	"""
	{   "Subnets": [
          {
              "VpcId": "my_vpc_id",
              "CidrBlock": "10.0.1.0/24",
              "MapPublicIpOnLaunch": false,
              "DefaultForAz": false,
              "State": "available",
              "SubnetId": "subnet-XXXXXX",
              "AvailableIpAddressCount": 251
           },
           {
              "VpcId": "my_vpc_id",
              "CidrBlock": "10.0.0.0/24",
              "MapPublicIpOnLaunch": false,
              "DefaultForAz": false,
              "State": "available",
              "SubnetId": "subnet-YYYYYY",
              "AvailableIpAddressCount": 251
           }  ]   }
	"""
	And I double `aws --output json --region us-west-1 ec2 describe-security-groups --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=mysecuritygroup'` with stdout:
	"""
	  {
		  "SecurityGroups": [
			  {
				  "Description": "My security group",
				  "GroupName": "my_security_group_name",
				  "OwnerId": "123456789012",
				  "GroupId": "sg-903004f8"
			  }
		  ]
	  }
    """
    And I double `aws --region us-west-1 ec2 run-instances --image-id ami-abc123 --key-name sshkey --instance-type x1-large --placement AvailabilityZone=us-west-1a,Tenancy=dedicated --block-device-mappings '[{"DeviceName":"/dev/sda1","Ebs":{"DeleteOnTermination":true,"SnapshotId":"snap-XXX","VolumeSize":70,"VolumeType":"standard"}}]' --enable-api-termination --client-token test_token --network-interfaces '[{"Groups":["sg-903004f8"],"PrivateIpAddress":"10.0.0.6","DeviceIndex":0,"SubnetId":"subnet-YYYYYY"}]' --ebs-optimized` with stdout:
    """
	   { "Instances" : [ {"InstanceId": "i-XXXXXXX","Tags": [ ] } ] } 
	"""
	And I double `aws --output json --region us-west-1 ec2 create-tags --resources id-XXXXXXX --tags Key=externalid,Value=my_instance` with stdout:
	"""
      { "return":"true" }
    """
	And I double `aws --output json --region us-west-1 ec2 create-tags --resources id-XXXXXXX --tags Key=Name,Value=my_instance` with stdout:
	"""
      { "return":"true" }
    """
	And I double `aws --output json --region us-west-1 ec2 modify-instance-attribute --instance-id=id-XXXXXXX --no-source-dest-check` with stdout:
	"""
      { "return":"true" }
    """
	Given an empty file named "undo.sh.1" 
    When I run `bundle exec zaws compute declare my_instance ami-abc123 self x1-large 70 us-west-1a sshkey mysecuritygroup --privateip "10.0.0.6" --region us-west-1 --vpcid my_vpc_id --optimized --apiterminate --clienttoken test_token --tenancy dedicated --undofile undo.sh.1 --skipruncheck --verbose`
	Then the output should contain "Instance created.\n" 
	And the file "undo.sh.1" should contain "zaws compute delete my_instance --region us-west-1 --vpcid my_vpc_id $XTRA_OPTS"
		
  Scenario: Declare a compute instance in vpc by external id, skip 
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-XXXXXXX","Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
    When I run `bundle exec zaws compute declare my_instance ami-abc123 self x1-large 70 us-west-1a sshkey mysecuritygroup --privateip "10.0.0.6" --region us-west-1 --vpcid my_vpc_id --optimized --apiterminate --clienttoken test_token --skipruncheck`
	Then the output should contain "Instance already exists. Creation skipped.\n" 
	

  Scenario: Delete
   Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-XXXXXXX","Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
   Given I double `aws --region us-west-1 ec2 terminate-instances --instance-ids i-XXXXXXX` with stdout:
     """
	 {  "TerimatingInstances": [ ] } 
	 """
    When I run `bundle exec zaws compute delete my_instance --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "Instance deleted.\n" 
	  
  Scenario: Delete, skip
   Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [] } 
	 """
    When I run `bundle exec zaws compute delete my_instance --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "Instance does not exist. Skipping deletion.\n" 
			
  Scenario: Nagios OK
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-XXXXXXX","Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
    When I run `bundle exec zaws compute declare my_instance ami-abc123 self x1-large 70 us-west-1a sshkey mysecuritygroup --privateip "10.0.0.6" --region us-west-1 --vpcid my_vpc_id --optimized --apiterminate --clienttoken test_token --nagios --skipruncheck`
	Then the output should contain "OK: Instance already exists.\n" 
	  
  Scenario: Nagios CRITICAL
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [] } 
	 """
    When I run `bundle exec zaws compute declare my_instance ami-abc123 self x1-large 70 us-west-1a sshkey mysecuritygroup --privateip "10.0.0.6" --region us-west-1 --vpcid my_vpc_id --optimized --apiterminate --clienttoken test_token --nagios --skipruncheck`
	Then the output should contain "CRITICAL: Instance does not exist.\n" 



