Feature: Instance Registration 

  Scenario: Declare instance registration
	Given I double `aws --output json --region us-west-1 elb describe-load-balancers` with stdout:
     """
	 { "LoadBalancerDescriptions": [ { "LoadBalancerName": "lbname", "Instances": [ ] } ] }
     """
    And I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-X","Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
    And I double `aws --region us-west-1 elb register-instances-with-load-balancer --load-balancer-name lbname --instances i-X` with stdout:
     """
	 { "Instances" : [ { "InstanceId": "i-X" } ]  } 
	 """
    When I run `bundle exec zaws load_balancer register_instance lbname my_instance --region us-west-1 --vpcid my_vpc_id`
	Then the stdout should contain "New instance registered.\n" 

  Scenario: Declare instance registration, Skip creation
    Given I double `aws --output json --region us-west-1 elb describe-load-balancers` with stdout:
     """
	 { "LoadBalancerDescriptions": [ { "LoadBalancerName": "lbname", "Instances": [ { "InstanceId": "i-X" }  ]} ] }
     """
    And I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-X","Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
    When I run `bundle exec zaws load_balancer register_instance lbname my_instance --region us-west-1 --vpcid my_vpc_id`
	Then the stdout should contain "Instance already registered. Skipping registration.\n" 

  Scenario: Delete
   Given I double `aws --output json --region us-west-1 elb describe-load-balancers` with stdout:
     """
	 { "LoadBalancerDescriptions": [ { "LoadBalancerName": "lbname", "Instances": [ { "InstanceId": "i-X" }  ]} ] }
     """
    And I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-X","Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
    And I double `aws --region us-west-1 elb deregister-instances-with-load-balancer --load-balancer-name lbname --instances i-X` with stdout:
     """
	 { "return" : "true" } 
	 """
    When I run `bundle exec zaws load_balancer deregister_instance lbname my_instance --region us-west-1 --vpcid my_vpc_id`
	Then the stdout should contain "Instance deregistered.\n" 

  Scenario: Delete, skip
	Given I double `aws --output json --region us-west-1 elb describe-load-balancers` with stdout:
     """
	 { "LoadBalancerDescriptions": [ { "LoadBalancerName": "lbname", "Instances": [ ] } ] }
     """
    And I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-X","Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
	When I run `bundle exec zaws load_balancer deregister_instance lbname my_instance --region us-west-1 --vpcid my_vpc_id`
	Then the stdout should contain "Instance not registered. Skipping deregistration.\n" 

  Scenario: Undo file
   Given I double `aws --output json --region us-west-1 elb describe-load-balancers` with stdout:
     """
	 { "LoadBalancerDescriptions": [ { "LoadBalancerName": "lbname", "Instances": [ { "InstanceId": "i-X" }  ]} ] }
     """
    And I double `aws --output json --region us-west-1 ec2 describe-instances --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=tag:externalid,Values=my_instance'` with stdout:
     """
	 {  "Reservations": [ { "Instances" : [ {"InstanceId": "i-X","Tags": [ { "Value": "my_instance","Key": "externalid" } ] } ] } ] } 
	 """
	Given an empty file named "undo.sh.1" 
    When I run `bundle exec zaws load_balancer register_instance lbname my_instance --region us-west-1 --vpcid my_vpc_id --undofile undo.sh.1`
    Then the stdout should contain "Instance already registered. Skipping registration.\n" 
	And the file "undo.sh.1" should contain "zaws load_balancer deregister_instance lbname my_instance --region us-west-1 --vpcid my_vpc_id $XTRA_OPTS"

