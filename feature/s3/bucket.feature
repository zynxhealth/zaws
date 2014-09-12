Feature: S3 Bucket
  S3 buckets can be managed

  Scenario: Declare an S3 bucket by name but skip creation (already exists)
    Given I double `aws --region us-west-1 s3 ls` with "2014-08-25 15:49:19 test-bucket"
    When I run `bundle exec zaws bucket declare test-bucket --region us-west-1`
    Then the output should contain "Bucket already exists. Creation skipped.\n"

  Scenario: Move the entire contents of an s3 bucket to the specified directory
    Given I double `aws s3 cp test-bucket /tmp/dir --region us-west-1 --recursive` with "S3Output"
    When I run `bundle exec zaws bucket get test-bucket --dest /tmp/dir --region us-west-1`
    Then the output should contain "S3Output"