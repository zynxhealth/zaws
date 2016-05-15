require 'json'
require 'digest/sha1'
require 'fileutils'
require 'zlib'

module ZAWS
  class CloudTrail
    DEFAULT_DAYS_TO_FETCH=7
    ZAWS_S3_CACHE="#{Dir.home}/.zaws/s3-cache"

    def initialize(shellout,aws)
      @shellout=shellout
      @aws=aws
    end

    def get_cloud_trail_by_bucket(region,bucket_name,as_raw=false,verbose=nil)
      bucket_name = "s3://#{bucket_name}" if !bucket_name.match('s3://.*')
      bucket_hash = Digest::SHA1.hexdigest("#{region}#{bucket_name}")

      dir_name = "#{ZAWS_S3_CACHE}/#{bucket_hash}"
      FileUtils.mkdir_p(dir_name)

      dir_name = @aws.s3.bucket.sync(region,bucket_name,dir_name,verbose)

      results = []
      Dir.open(dir_name) { |dir|
        Dir.glob(File.join(dir, '**', '*')) { |filename|
          Zlib::GzipReader.open(filename) { |file|
            log_file = JSON.parse file.read
            results.push log_file['Records']
          } if File.file? filename
        }
      }
        json = {:Records => results.flatten(1)}.to_json

      if as_raw
        puts json
      else
        puts ZAWS::Helper::Output.cloudtrail(json)
      end

      json
    end

    def get_cloud_trail_by_name(region,trail_name,as_raw=false, verbose=nil)
      available_cloud_trails = get_cloud_trails(region)
      bucket_name = available_cloud_trails.find { |available_cloud_trail|
        available_cloud_trail['Name'] === trail_name
      }['S3BucketName']

      get_cloud_trail_by_bucket(region, bucket_name, as_raw, verbose)
    end

    def get_cloud_trails(region, verbose=nil)
      com_line   = "aws cloudtrail describe-trails --region #{region}"
      cloud_trails = JSON.parse @shellout.cli(com_line, verbose)
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