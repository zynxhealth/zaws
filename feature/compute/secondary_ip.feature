Feature: Compute 
    
  Scenario: Determine secondary ip exists on instance by external ip
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-XXXXXXX", 
	                                         "NetworkInterfaces" : [ { "PrivateIpAddresses" : [ { "PrivateIpAddress" : "0.0.0.0"  } ] } ], 
	                                         "Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
    When I run `zaws compute exists_secondary_ip my_instance 0.0.0.0 --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "true\n" 
	 
  Scenario: Determine secondary ip does not exist on instance by external ip
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-XXXXXXX", 
	                                         "NetworkInterfaces" : [ { "PrivateIpAddresses" : [ { "PrivateIpAddress" : "0.0.0.1"  } ] } ], 
	                                         "Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
    When I run `zaws compute exists_secondary_ip my_instance 0.0.0.0 --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "false\n" 
	
  Scenario: Declare secondary ip for instance by external ip
   Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-XXXXXXX", 
                                          	 "NetworkInterfaces" : [ { "NetworkInterfaceId": "net-123", "PrivateIpAddresses" : [ { "PrivateIpAddress" : "0.0.0.1"  } ] } ], 
	                                         "Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
	 Given I double `aws --output json --region us-west-1 ec2 assign-private-ip-addresses --network-interface-id 'net-123' --private-ip-addresses '0.0.0.0'` with stdout:
     """
	 { "return" : "true" }
	 """
    When I run `zaws compute declare_secondary_ip my_instance 0.0.0.0 --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "Secondary ip assigned.\n" 
	
  Scenario: Skip declaring secondary ip for instance by external ip because it exists already.
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-XXXXXXX", 
	                                         "NetworkInterfaces" : [ { "PrivateIpAddresses" : [ { "PrivateIpAddress" : "0.0.0.0"  } ] } ], 
	                                         "Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
    When I run `zaws compute declare_secondary_ip my_instance 0.0.0.0 --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "Secondary ip already exists. Skipping assignment.\n" 
	 
  Scenario: Delete
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-XXXXXXX", 
	                                         "NetworkInterfaces" : [ { "NetworkInterfaceId": "net-123", "PrivateIpAddresses" : [ { "PrivateIpAddress" : "0.0.0.0"  } ] } ], 
	                                         "Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
    Given I double `aws --output json --region us-west-1 ec2 unassign-private-ip-addresses --network-interface-id 'net-123' --private-ip-addresses '0.0.0.0'` with stdout:
     """
	 { "return" : "true" }
	 """
    When I run `zaws compute delete_secondary_ip my_instance 0.0.0.0 --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "Secondary ip deleted.\n" 
	
  Scenario: Delete, skip
	Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-XXXXXXX", 
	                                         "NetworkInterfaces" : [ { "PrivateIpAddresses" : [ { "PrivateIpAddress" : "0.0.0.1"  } ] } ], 
	                                         "Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
    When I run `zaws compute delete_secondary_ip my_instance 0.0.0.0 --region us-west-1 --vpcid my_vpc_id`
	Then the output should contain "Secondary IP does not exists, skipping deletion.\n" 
				
  Scenario: Nagios OK
   Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-XXXXXXX", 
                                          	 "NetworkInterfaces" : [ { "NetworkInterfaceId": "net-123", "PrivateIpAddresses" : [ { "PrivateIpAddress" : "0.0.0.0"  } ] } ], 
	                                         "Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
    When I run `zaws compute declare_secondary_ip my_instance 0.0.0.0 --region us-west-1 --vpcid my_vpc_id --nagios`
	Then the output should contain "OK: Secondary ip exists.\n" 
	
  Scenario: Nagios CRITICAL
   Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-XXXXXXX", 
                                          	 "NetworkInterfaces" : [ { "NetworkInterfaceId": "net-123", "PrivateIpAddresses" : [ { "PrivateIpAddress" : "0.0.0.1"  } ] } ], 
	                                         "Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
    When I run `zaws compute declare_secondary_ip my_instance 0.0.0.0 --region us-west-1 --vpcid my_vpc_id --nagios`
	Then the output should contain "CRITICAL: Secondary ip does not exist.\n" 
	
  Scenario: Undo file
   Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-XXXXXXX", 
                                          	 "NetworkInterfaces" : [ { "NetworkInterfaceId": "net-123", "PrivateIpAddresses" : [ { "PrivateIpAddress" : "0.0.0.1"  } ] } ], 
	                                         "Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
	 Given I double `aws --output json --region us-west-1 ec2 assign-private-ip-addresses --network-interface-id 'net-123' --private-ip-addresses '0.0.0.0'` with stdout:
     """
	 { "return" : "true" }
	 """
	Given an empty file named "undo.sh.1" 
    When I run `zaws compute declare_secondary_ip my_instance 0.0.0.0 --region us-west-1 --vpcid my_vpc_id --undofile undo.sh.1`
	Then the output should contain "Secondary ip assigned.\n" 
	And the file "undo.sh.1" should contain "zaws compute delete_secondary_ip my_instance 0.0.0.0 --region us-west-1 --vpcid my_vpc_id $XTRA_OPTS"
	
    
