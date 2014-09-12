require 'json'

module ZAWS
  class CloudTrail

    def initialize(shellout,aws)
      @shellout=shellout
      @aws=aws
    end

    def get_cloud_trail_by_bucket(region,bucket_name)
      comLine = "aws fakecall --bucket #{bucket_name}"
      puts @shellout.cli(comLine, $stdout)
    end

    def get_cloud_trail_by_name(region, trail_name)
      available_cloud_trails = get_cloud_trails(region)
      bucket_name = available_cloud_trails.find { |available_cloud_trail|
        available_cloud_trail['Name'] === trail_name
      }['S3BucketName']

      get_cloud_trail_by_bucket(region, bucket_name)
    end

    def get_cloud_trails(region, verbose=nil)
      comLine = "aws cloudtrail describe-trails --region #{region}"
      cloud_trails = JSON.parse @shellout.cli(comLine, verbose)
      cloud_trails['trailList']
    end

  end
end