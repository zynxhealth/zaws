require 'thor'

module ZAWS
  module Command
  class Bucket < Thor
    class_option :region, :type => :string, :desc => "AWS Region", :banner => "<region>",  :aliases => :r, :required => true

    desc "declare BUCKET_NAME", "declare an S3 bucket."
    def declare(name)
      aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
      aws.s3.bucket.declare(name,options[:region],$stdout)
    end

    desc "get BUCKET_NAME", "download the contents of an S3 bucket."
    option :dest, :type => :string, :desc => "directory to save to.", :aliases => :d
    def get(bucket_name)
      aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
      aws.s3.bucket.get(options[:region], bucket_name, options[:dest])
    end
  end
  end
end
