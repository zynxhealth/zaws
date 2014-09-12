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

  Scenario: Declare a CloudTrail by name but skip actual creation because it already exists
    Given I double `aws cloudtrail describe-trails --region us-west-1` with stdout:
    """
    {
      "trailList": [
        { "Name": "test-cloudtrail", "S3BucketName": "does-not-matter"}
      ]
    }
    """
    When I run `bundle exec zaws cloud_trail declare test-cloudtrail --region us-west-1`
    Then the output should contain "CloudTrail already exists. Creation skipped.\n"

  Scenario: Declare a CloudTrail by name that is actually created because it doesn't yet exist
    Given I double `aws cloudtrail describe-trails --region us-west-1` with stdout:
    """
    {
      "trailList": []
    }
    """
    And I double `aws --region us-west-1 cloudtrail create-subscription --name test-cloudtrail --s3-new-bucket zaws-cloudtrail-test-cloudtrail` with stdout:
    """
Setting up new S3 bucket zaws-cloudtrail-test-cloudtrail...
Creating/updating CloudTrail configuration...
CloudTrail configuration:
{
  "trailList": [
    {
      "IncludeGlobalServiceEvents": true,
      "Name": "test-cloudtrail",
      "S3BucketName": "zaws-cloudtrail-test-cloudtrail"
    }
  ]
}
Starting CloudTrail service...
Logs will be delivered to zaws-cloudtrail-test-cloudtrail:
    """
    When I run `bundle exec zaws cloud_trail declare test-cloudtrail --region us-west-1`
    Then the output should contain "Logs will be delivered to zaws-cloudtrail-test-cloudtrail"
