Feature: Listner

  Scenario: Determine listner exists
	Given I double `aws --output json --region us-west-1 elb describe-load-balancers` with stdout:
     """
	  { "LoadBalancerDescriptions": [ { "LoadBalancerName": "lbname", "ListenerDescriptions": [ { "Listener": { "InstancePort": 80, "LoadBalancerPort": 80, "Protocol": "HTTP", "InstanceProtocol": "HTTP" }, "PolicyNames": [] } ] } ] }
     """
    When I run `bundle exec zaws load_balancer exists_listener lbname HTTP 80 HTTP 80 --region us-west-1`
	Then the stdout should contain "true\n" 
		
  Scenario: Determine listner does not exist
	Given I double `aws --output json --region us-west-1 elb describe-load-balancers` with stdout:
     """
	  { "LoadBalancerDescriptions": [ { "LoadBalancerName": "lbname", "ListenerDescriptions": [ { "Listener": { "InstancePort": 17080, "LoadBalancerPort": 80, "Protocol": "HTTP", "InstanceProtocol": "HTTP" }, "PolicyNames": [] } ] } ] }
     """
    When I run `bundle exec zaws load_balancer exists_listener lbname tcp 80 tcp 80 --region us-west-1`
	Then the stdout should contain "false\n" 

  Scenario: Declare listner 
    Given I double `aws --output json --region us-west-1 elb describe-load-balancers` with stdout:
     """
	  { "LoadBalancerDescriptions": [ { "LoadBalancerName": "lbname", "ListenerDescriptions": [] } ] }
     """
    And I double `aws --region us-west-1 elb create-load-balancer-listeners --load-balancer-name lbname --listeners '[{"Protocol":"HTTP","LoadBalancerPort":80,"InstanceProtocol":"HTTP","InstancePort":80}]'` with stdout:
	 """
      { "return": "true" }
	 """
    When I run `bundle exec zaws load_balancer declare_listener lbname HTTP 80 HTTP 80 --region us-west-1`
	Then the stdout should contain "Listener created.\n" 
		
  Scenario: Declare listner, Skip creation
    Given I double `aws --output json --region us-west-1 elb describe-load-balancers` with stdout:
     """
	  { "LoadBalancerDescriptions": [ { "LoadBalancerName": "lbname", "ListenerDescriptions": [ { "Listener": { "InstancePort": 80, "LoadBalancerPort": 80, "Protocol": "HTTP", "InstanceProtocol": "HTTP" }, "PolicyNames": [] } ] } ] }
     """
    When I run `bundle exec zaws load_balancer declare_listener lbname HTTP 80 HTTP 80 --region us-west-1`
	Then the stdout should contain "Listerner exists. Skipping creation.\n" 
		
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

  Scenario: Undo file
    Given I double `aws --output json --region us-west-1 elb describe-load-balancers` with stdout:
     """
	  { "LoadBalancerDescriptions": [ { "LoadBalancerName": "lbname", "ListenerDescriptions": [ { "Listener": { "InstancePort": 80, "LoadBalancerPort": 80, "Protocol": "HTTP", "InstanceProtocol": "HTTP" }, "PolicyNames": [] } ] } ] }
     """
  	Given an empty file named "undo.sh.1" 
    When I run `bundle exec zaws load_balancer declare_listener lbname HTTP 80 HTTP 80 --region us-west-1 --undofile undo.sh.1`
	Then the stdout should contain "Listerner exists. Skipping creation.\n" 
	And the file "undo.sh.1" should contain "zaws load_balancer delete_listener lbname HTTP 80 HTTP 80 --region us-west-1 $XTRA_OPTS"



