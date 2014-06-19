require 'json'
require 'netaddr'
require 'timeout'

module ZAWS
  module Route53Services
	class HostedZone 

	  def initialize(shellout,aws)
		@shellout=shellout
		@aws=aws
	  end

 	  def view(viewtype,textout=nil,verbose=nil)
		comline="aws --output #{viewtype} route53 list-hosted-zones"
		zones=@shellout.cli(comline,verbose)
		textout.puts(zones) if textout
		return zones 
	  end

	  def view_records(viewtype,textout=nil,verbose=nil,zonename)
        zones=JSON.parse(view('json',nil,verbose))
		zone_id=nil
		zones["HostedZones"].each { |x| zone_id = ("#{x["Name"]}"=="#{zonename}") ? x["Id"] : nil }
        if zone_id
		  comline="aws --output #{viewtype} route53 list-resource-record-sets --hosted-zone-id #{zone_id}"
		  records=@shellout.cli(comline,verbose)
		  textout.puts(records) if textout
		  return records 
		end
	  end

	end
  end
end

