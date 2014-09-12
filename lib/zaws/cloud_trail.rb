require 'json'

module ZAWS
  class CloudTrail
    DEFAULT_DAYS_TO_FETCH=7

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

    def exists(name,region)
      get_cloud_trails(region).any? {|trail| trail['Name'] === name}
    end

    def declare(name,region,bucket_name,verbose=nil)
      if exists(name,region)
        puts "CloudTrail already exists. Creation skipped.\n"
      else
        bucket_exists=@aws.s3.bucket().exists(bucket_name,region)
        cmdline = "aws --region #{region} cloudtrail create-subscription " <<
            "--name #{name} --s3-#{bucket_exists ? 'use' : 'new'}-bucket #{bucket_name}"
        puts @shellout.cli(cmdline,verbose)
      end
    end

  end
end