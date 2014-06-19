Feature: View Record
    
  Scenario: Get records for hosted zone in a human readable table. 
	Given I double `aws --output json route53 list-hosted-zones` with stdout:
	"""
	{   "HostedZones": [  {  "Id": "id-???", "Name": "abc.com." } ] }
	"""
	And I double `aws --output table route53 list-resource-record-sets --hosted-zone-id id-???` with "AWS Resource Record Sets Output" 
    When I run `zaws hosted_zone view_records abc.com. --viewtype table`
    Then the stdout should contain "AWS Resource Record Sets Output\n" 

  Scenario: Get records for hosted zone in a human readable table form by default
	Given I double `aws --output json route53 list-hosted-zones` with stdout:
	"""
	{   "HostedZones": [  {  "Id": "id-???", "Name": "abc.com." } ] }
	"""
	And I double `aws --output table route53 list-resource-record-sets --hosted-zone-id id-???` with "AWS Resource Record Sets Output" 
    When I run `zaws hosted_zone view_records abc.com.`
    Then the stdout should contain "AWS Resource Record Sets Output\n" 

  Scenario: Get records for hosted zone in a JSON form. 
	Given I double `aws --output json route53 list-hosted-zones` with stdout:
	"""
	{   "HostedZones": [  {  "Id": "id-???", "Name": "abc.com." } ] }
	"""
	And I double `aws --output json route53 list-resource-record-sets --hosted-zone-id id-???` with "AWS Resource Record Sets Output" 
    When I run `zaws hosted_zone view_records abc.com. --viewtype json`
    Then the stdout should contain "AWS Resource Record Sets Output\n" 

