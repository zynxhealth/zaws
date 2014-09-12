require 'thor'

module ZAWS
  module Command
	class CloudTrail < Thor
	  class_option :region, :type => :string, :desc => "AWS Region", :banner => "<region>",  :aliases => :r, :required => true

	  desc "view","View a cloud trail"
    option :trailName, :type => :string, :desc => "Name of the cloud trail to view", :aliases => :n
    option :bucket, :type => :string, :desc => "Name of the bucket where the cloud trail is stored", :aliases => :b
    def view
      aws=(ZAWS::AWS.new(ZAWS::Helper::Shell.new))
      if options[:bucket]
        aws.cloud_trail.get_cloud_trail_by_bucket(options[:region], options[:bucket])
      else
        aws.cloud_trail.get_cloud_trail_by_name(options[:region], options[:trailName] ? options[:trailName] : 'default')
      end
    end
	end
  end
end


