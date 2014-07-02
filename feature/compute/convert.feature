Feature: Convert Instances From State A to State B
  Reliable, Repeatable conversions of instances from one state to another.
    
  Scenario: Create a new dedicated tenancy instance out of a stopped instance and an migrate the following: elastic ip, security group
	# Determine if new instance already exists
    Given I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=new_instance'` with stdout:
     """
	  {  "Reservations": [] } 
	 """
    # Determine if the source instance exists and extract information
	And I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=instance-id,Values=i-abababab'` with stdout:
     """
     {  "Reservations": [
		{  "Instances": [
				{
					"State": {
						"Code": 80,
						"Name": "stopped"
					},
					"EbsOptimized": false,
					"PrivateIpAddress": "172.30.1.7",
					"InstanceId": "i-abababab",
					"KeyName": "AccessKey",
					"SecurityGroups": [
						{
							"GroupName": "my_security_group",
							"GroupId": "sg-cdcdcdcd"
						}
					],
					"InstanceType": "t1.micro",
					"SourceDestCheck": false,
					"Placement": {
						"Tenancy": "default"
					},
					"IamInstanceProfile": {
						"Arn": "arn:aws:iam::123456789012:instance-profile/nat"
					}
				}
			]
		}
		] }
	 """
	# Check for elastic ip associated to source image and use it if it exists
    And I double `aws --output json --region us-west-1 ec2 describe-addresses --filter 'Name=domain,Values=vpc' 'Name=private-ip-address,Values=172.30.1.7'` with stdout:
     """
	 {  "Addresses": [ { "InstanceId" : "i-abababab", "PublicIp": "55.55.55.55", "Domain": "vpc", "PrivateIpAddress": "172.30.1.7","AssociationId": "eipassoc-abcd1234","AllocationId": "eipalloc-abcd1234"  } ] }
	 """
    # Create the new image from the existing instance	
	And I double `aws create-image --instance-id i-abababab --name ami-from-i-abababab`
     """
	 { "ImageId": "ami-abcd1234" }
	 """
	# Insure the new image has been created
    And I double `aws --output json --region us-west-1 ec2 describe-images --owner self --image-ids ami-abcd1234` with stdout:
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
	# Get the subnet id and availability zone for the specified private ip address for the new instance
	And I double `aws --output json --region us-west-1 ec2 describe-subnets --filter 'Name=vpc-id,Values=my_vpc_id'` with stdout:
	"""
	{   "Subnets": [
          {
              "VpcId": "my_vpc_id",
              "CidrBlock": "172.30.1.0/24",
              "MapPublicIpOnLaunch": false,
              "DefaultForAz": false,
              "State": "available",
              "SubnetId": "subnet-abc123",
			  "AvailabilityZone": "us-west-1a",
              "AvailableIpAddressCount": 251
           }  ]   }
	"""
	# Create the new instance from the newly create AMI, using the override specified for dedicated tenancy
	And I double `aws --region us-west-1 ec2 run-instances --image-id ami-abcd1234 --key-name AccessKey --instance-type t1.micro --placement AvailabilityZone=us-west-1a,Tenancy=dedicated --client-token test_token --network-interfaces '[{"Groups":["sg-903004f8"],"PrivateIpAddress":"172.30.1.8","DeviceIndex":"0","SubnetId":"subnet-abc123"}]' --client-token test_token` with stdout:
    """
	   { "Instances" : [ {"InstanceId": "i-adadadad","Tags": [ ] } ] } 
	"""
	# Add a new tag.
	And I double `aws --output json --region us-west-1 ec2 create-tags --resources id-adadadad --tags Key=externalid,Value=my_instance` with stdout:
	"""
      { "return":"true" }
    """
	# Add a new tag.
	And I double `aws --output json --region us-west-1 ec2 create-tags --resources id-adadadad --tags Key=Name,Value=my_instance` with stdout:
	"""
      { "return":"true" }
    """
	# Re-associate elasticip from previous instance to new instance
	And I double `aws --region us-west-1 ec2 disassociate-address --public-ip 55.55.55.55 --association-id eipassoc-abcd1234` with stdout:
     """
	 {  "return": "true" }
	 """
	And I double `aws --region us-west-1 ec2 associate-address --instance-id i-adadadad --public-ip 55.55.55.55 --allocation-id eipalloc-abcd1234` with stdout:
     """
	 {  "return": "true" }
	 """
    When I run `bundle exec zaws compute convert i-abababab new_instance 172.30.1.8 --region us-west-1 --vpcid my_vpc_id --tenancy dedicated`
	Then the output should contain "true\n" 
	

