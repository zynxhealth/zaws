Feature: Version 
  Should allow for getting the version of zaws.
    
  Scenario: Get zaws version  
    When I run `zaws version`
    Then the output should contain "zaws version 0.0.1"
