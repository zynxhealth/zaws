Feature: Cloud Trail

  Scenario: Get default cloud trail for region if no bucket name or trail name given
    Given I double `aws cloudtrail describe-trails --region us-west-1` with stdout:
    """
    {
      "trailList": [
        { "Name": "dontGetMe", "S3BucketName": "dontUseMe"},
        { "Name": "default", "S3BucketName": "bucketName"}
      ]
    }
    """
    And I double `aws fakecall --bucket bucketName` with "FakeCallOutput"
    When I run `bundle exec zaws cloud_trail view --region us-west-1`
    Then the output should contain "FakeCallOutput"
  
  Scenario: Get specified cloud trail for region if trail name given
    Given I double `aws cloudtrail describe-trails --region us-west-1` with stdout:
    """
    {
      "trailList": [
        { "Name": "namedTrail", "S3BucketName": "bucketName"},
        { "Name": "default", "S3BucketName": "dontUseMe"}
      ]
    }
    """
    And I double `aws fakecall --bucket bucketName` with "FakeCallOutput"
    When I run `bundle exec zaws cloud_trail view --region us-west-1 --trailName namedTrail`
    Then the output should contain "FakeCallOutput"

  Scenario: Get specified cloud trail for region if bucket name given
    Given I double `aws fakecall --bucket bucketName` with "FakeCallOutput"
    When I run `bundle exec zaws cloud_trail view --region us-west-1 --bucket bucketName`
    Then the output should contain "FakeCallOutput"