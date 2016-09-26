Feature: Listner

  Scenario: Delete
    Given I double `aws --output json --region us-west-1 elb describe-load-balancers` with stdout:
     """
	  { "LoadBalancerDescriptions": [ { "LoadBalancerName": "lbname", "ListenerDescriptions": [ { "Listener": { "InstancePort": 80, "LoadBalancerPort": 80, "Protocol": "HTTP", "InstanceProtocol": "HTTP" }, "PolicyNames": [] } ] } ] }
     """
    And I double `aws --region us-west-1 elb delete-load-balancer-listeners --load-balancer-name lbname --load-balancer-ports 80` with stdout:
	 """
      { "return": "true" }
	 """
    When I run `bundle exec zaws load_balancer delete_listener lbname HTTP 80 HTTP 80 --region us-west-1`
	Then the stdout should contain "Listerner deleted.\n" 
	
  Scenario: Delete, skip
    Given I double `aws --output json --region us-west-1 elb describe-load-balancers` with stdout:
     """
	  { "LoadBalancerDescriptions": [ { "LoadBalancerName": "lbname", "ListenerDescriptions": [] } ] }
     """
    When I run `bundle exec zaws load_balancer delete_listener lbname HTTP 80 HTTP 80 --region us-west-1`
	Then the stdout should contain "Listener does not exist. Skipping deletion.\n" 

