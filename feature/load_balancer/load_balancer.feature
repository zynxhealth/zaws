Feature: Load Balancer 
    

  Scenario: Delete
   Given I double `aws --output json --region us-west-1 elb describe-load-balancers` with stdout:
     """
      { "LoadBalancerDescriptions": [ { "LoadBalancerName": "name-???" }] }
     """
   And I double `aws --region us-west-1 elb delete-load-balancer --load-balancer-name name-???` with stdout:
	 """
      { "return": "true" }
	 """
    When I run `bundle exec zaws load_balancer delete "name-???" --region us-west-1`
    Then the stdout should contain "Load balancer deleted.\n" 

  Scenario: Delete, skip
   Given I double `aws --output json --region us-west-1 elb describe-load-balancers` with stdout:
     """
      { "LoadBalancerDescriptions": [ ] }
     """
    When I run `bundle exec zaws load_balancer delete name-??? --region us-west-1`
    Then the stdout should contain "Load balancer does not exist. Skipping deletion.\n" 

  Scenario: Undo file
   Given I double `aws --output json --region us-west-1 elb describe-load-balancers` with stdout:
     """
      { "LoadBalancerDescriptions": [ { "LoadBalancerName": "name-???" } ] }
     """
	Given an empty file named "undo.sh.1" 
    When I run `bundle exec zaws load_balancer create_in_subnet name-??? tcp 80 tcp 80 my_security_group_name --cidrblocks="10.0.0.0/28" "10.0.1.0/28" --vpcid my_vpc_id --region us-west-1 --undofile undo.sh.1`
    Then the stdout should contain "Load balancer already exists. Skipping creation.\n" 
	And the file "undo.sh.1" should contain "zaws load_balancer delete name-??? --region us-west-1 $XTRA_OPTS"

    


