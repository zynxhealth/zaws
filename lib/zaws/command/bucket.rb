require 'thor'

module ZAWS
  module Command
  class Bucket < Thor
    class_option :region, :type => :string, :desc => "AWS Region", :banner => "<region>",  :aliases => :r, :required => true

    desc "declare BUCKET_NAME", "declare an S3 bucket."
    def declare(name)
      aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
      aws.s3.bucket.declare(name, $stdout)
    end

  end
  end
end
