Feature: View images 
    
  Scenario: Get compute images in a human readable table. 
    Given I double `aws --output table --region us-west-1 ec2 describe-images --owner self` with "AWS Compute Output" 
    When I run `bundle exec zaws compute view_images --region us-west-1 --viewtype table`
    Then the stdout should contain "AWS Compute Output\n" 

  Scenario: Get compute images in a human readable table form by default 
    Given I double `aws --output table --region us-west-1 ec2 describe-images --owner self` with "AWS Compute Output" 
    When I run `bundle exec zaws compute view_images --region us-west-1`
    Then the stdout should contain "AWS Compute Output\n" 

  Scenario: Get compute images in JSON form 
    Given I double `aws --output json --region us-west-1 ec2 describe-images --owner self` with "AWS Compute JSON Output" 
    When I run `bundle exec zaws compute view_images --region us-west-1 --viewtype json`
    Then the stdout should contain "AWS Compute JSON Output\n" 

  Scenario: Get compute images for a specific owner in JSON form 
    Given I double `aws --output json --region us-west-1 ec2 describe-images --owner me` with "AWS Compute JSON Output" 
    When I run `bundle exec zaws compute view_images --region us-west-1 --viewtype json --owner me`
    Then the stdout should contain "AWS Compute JSON Output\n" 

	

