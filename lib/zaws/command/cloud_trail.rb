require 'thor'

module ZAWS
  module Command
	class Cloud_Trail < Thor
	  class_option :region, :type => :string, :desc => "AWS Region", :banner => "<region>",  :aliases => :r, :required => true

	  desc "view","View a cloud trail"
    option :trail, :type => :string, :desc => "Name of the cloud trail to view", :aliases => :n
    option :bucket, :type => :string, :desc => "Name of the bucket where the cloud trail is stored", :aliases => :b
    def view

    end
	end
  end
end


