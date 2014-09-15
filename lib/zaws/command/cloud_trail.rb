require 'thor'

module ZAWS
  module Command
	class CloudTrail < Thor
	  class_option :region, :type => :string, :desc => "AWS Region", :banner => "<region>",  :aliases => :r, :required => true

	  desc "view","View a cloud trail"
    option :trailName, :type => :string, :desc => "Name of the cloud trail to view", :aliases => :n
    option :bucket, :type => :string, :desc => "Name of the bucket where the cloud trail is stored", :aliases => :b
    option :raw, :type => :boolean, :desc => "Return the cloud trail in its raw, json format", :aliases => :w, :default => false
    def view
      aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
      if options[:bucket]
        aws.cloud_trail.get_cloud_trail_by_bucket(options[:region], options[:bucket], options[:raw], options[:verbose]?$stdout:nil)
      else
        aws.cloud_trail.get_cloud_trail_by_name(options[:region], options[:trailName] ? options[:trailName] : 'default', options[:raw], options[:verbose]?$stdout:nil)
      end
    end

    desc "declare TRAIL_NAME","Declare a cloud trail"
    option :bucket, :type => :string, :desc => "Name of the bucket where the cloud trail is to be stored", :aliases => :b
    def declare(name)
      aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
      aws.cloud_trail.declare(name,options[:region],options[:bucket] ? options[:bucket] : "zaws-cloudtrail-#{name}")
    end
	end
  end
end


