require 'json'
require 'netaddr'
require 'timeout'

module ZAWS
  module EC2Services
	class RouteTable 

	  def initialize(shellout,aws)
		@shellout=shellout
		@aws=aws
	  end

	  def view(region,view,textout=nil,verbose=nil,vpcid=nil,externalid=nil)
		comline="aws --output #{view} --region #{region} ec2 describe-route-tables"
		if vpcid || externalid 
		  comline = comline + " --filter"
		end
		comline = comline + " 'Name=vpc-id,Values=#{vpcid}'" if vpcid 
		comline = comline + " 'Name=tag:externalid,Values=#{externalid}'" if externalid 
		rtables=@shellout.cli(comline,verbose)
		textout.puts(rtables) if textout
		return rtables
	  end

	  def exists(region,textout=nil,verbose=nil,vpcid,externalid)
		rtable=JSON.parse(view(region,'json',nil,verbose,vpcid,externalid))
		val = (rtable["RouteTables"].count == 1)
        rtable_id = val ? rtable["RouteTables"][0]["RouteTableId"] : nil
		textout.puts val.to_s if textout
		return val, rtable_id
	  end

	  def declare(region,vpcid,externalid,nagios,textout=nil,verbose=nil,ufile=nil)
		if ufile
		  ZAWS::Helper::ZFile.prepend("zaws route_table delete #{externalid} --region #{region} --vpcid #{vpcid} $XTRA_OPTS",'#Delete route table',ufile)
		end
		rtable_exists, rtable_id = exists(region,nil,verbose,vpcid,externalid) 
		return ZAWS::Helper::Output.binary_nagios_check(rtable_exists,"OK: Route table exists.","CRITICAL: Route table does not exist.",textout) if nagios
		if not rtable_exists
		  comline="aws --region #{region} ec2 create-route-table --vpc-id #{vpcid}"
		  rtable=JSON.parse(@shellout.cli(comline,verbose))
		  rtableid=rtable["RouteTable"]["RouteTableId"]
		  tagline="aws --region #{region} ec2 create-tags --resources #{rtableid} --tags Key=externalid,Value=#{externalid}"
		  tagresult=JSON.parse(@shellout.cli(tagline,verbose))
          ZAWS::Helper::Output.out_change(textout,"Route table created with external id: my_route_table.") if tagresult["return"] == "true"
		else
          ZAWS::Helper::Output.out_no_op(textout,"Route table exists already. Skipping Creation.")
		end
		return 0
	  end

	  def delete(region,textout=nil,verbose=nil,vpcid,externalid)
		rtable_exists, rtable_id = exists(region,nil,verbose,vpcid,externalid) 
        if rtable_exists
          comline="aws --region #{region} ec2 delete-route-table --route-table-id #{rtable_id}"
          deletion=JSON.parse(@shellout.cli(comline,verbose))
          textout.puts "Route table deleted." if deletion["return"] == "true"
		else
		  textout.puts "Route table does not exist. Skipping deletion."
		end
	  end

	  def route_exists_by_instance(region,textout=nil,verbose=nil,vpcid,routetable,cidrblock,externalid)
		# Returns the answer, instance_id, route_table_id
        instance_id=@aws.ec2.compute.instance_id_by_external_id(region,externalid,vpcid,nil,verbose)
		return false, nil, nil if not instance_id
		rtable=JSON.parse(view(region,'json',nil,verbose,vpcid,routetable))
		val = (rtable["RouteTables"].count == 1) && rtable["RouteTables"][0]["Routes"].any? { |x| x["DestinationCidrBlock"]=="#{cidrblock}" && x["InstanceId"]=="#{instance_id}" }
		rtable_id = (rtable["RouteTables"].count == 1) ? rtable["RouteTables"][0]["RouteTableId"] : nil
		textout.puts val.to_s if textout
		return val, instance_id, rtable_id 
	  end

	  def declare_route(region,textout=nil,verbose=nil,vpcid,routetable,cidrblock,externalid,nagios,ufile)
        if ufile 
		  ZAWS::Helper::ZFile.prepend("zaws route_table delete_route #{routetable} #{cidrblock} --region #{region} --vpcid #{vpcid} $XTRA_OPTS",'#Delete route',ufile)
		end
        # TODO: Route exists already of a different type?
		route_exists, instance_id, rtable_id = route_exists_by_instance(region,nil,verbose,vpcid,routetable,cidrblock,externalid) 
		return ZAWS::Helper::Output.binary_nagios_check(route_exists,"OK: Route to instance exists.","CRITICAL: Route to instance does not exist.",textout) if nagios
		if not route_exists
		  comline="aws --region #{region} ec2 create-route --route-table-id #{rtable_id} --destination-cidr-block #{cidrblock} --instance-id #{instance_id}"
		  routereturn=JSON.parse(@shellout.cli(comline,verbose))
		  textout.puts "Route created to instance." if routereturn["return"] == "true"
		else
		  textout.puts "Route not created to instance. Skip creation."
		end
		return 0
	  end

	  def delete_route(region,textout=nil,verbose=nil,vpcid,routetable,cidrblock)
        rtable=JSON.parse(view(region,'json',nil,verbose,vpcid,routetable))
		val = (rtable["RouteTables"].count == 1) && rtable["RouteTables"][0]["Routes"].any? { |x| x["DestinationCidrBlock"]=="#{cidrblock}" }
        rtable_id = (rtable["RouteTables"].count == 1) ? rtable["RouteTables"][0]["RouteTableId"] : nil
        if val
          comline="aws --region #{region} ec2 delete-route --route-table-id #{rtable_id} --destination-cidr-block #{cidrblock}"
          deletion=JSON.parse(@shellout.cli(comline,verbose))
          textout.puts "Route deleted." if deletion["return"] == "true"
		else
		  textout.puts "Route does not exist. Skipping deletion."
		end
	  end

	  def route_exists_by_gatewayid(region,textout=nil,verbose=nil,vpcid,routetable,cidrblock,gatewayid)
		# Returns the answer, route_table_id
		rtable=JSON.parse(view(region,'json',nil,verbose,vpcid,routetable))
		val = (rtable["RouteTables"].count == 1) && rtable["RouteTables"][0]["Routes"].any? { |x| x["DestinationCidrBlock"]=="#{cidrblock}" && x["GatewayId"]=="#{gatewayid}" }
		rtable_id = (rtable["RouteTables"].count == 1) ? rtable["RouteTables"][0]["RouteTableId"] : nil
		textout.puts val.to_s if textout
		return val, rtable_id 
	  end


	  def declare_route_to_gateway(region,textout=nil,verbose=nil,vpcid,routetable,cidrblock,gatewayid,nagios,ufile)
        if ufile 
		  ZAWS::Helper::ZFile.prepend("zaws route_table delete_route #{routetable} #{cidrblock} --region #{region} --vpcid #{vpcid} $XTRA_OPTS",'#Delete route',ufile)
		end
        # TODO: Route exists already of a different type?
		route_exists, rtable_id = route_exists_by_gatewayid(region,nil,verbose,vpcid,routetable,cidrblock,gatewayid) 
		return ZAWS::Helper::Output.binary_nagios_check(route_exists,"OK: Route to gateway exists.","CRITICAL: Route to gateway does not exist.",textout) if nagios
		if not route_exists
		  comline="aws --region #{region} ec2 create-route --route-table-id #{rtable_id} --destination-cidr-block #{cidrblock} --gateway-id #{gatewayid}"
		  routereturn=JSON.parse(@shellout.cli(comline,verbose))
		  textout.puts "Route created to gateway." if routereturn["return"] == "true"
		else
		  textout.puts "Route to gateway exists. Skipping creation."
		end
		return 0
	  end

      def subnet_assoc_exists(region,textout=nil,verbose=nil,vpcid,rtable_externalid,cidrblock)
		rtable=JSON.parse(view(region,'json',nil,verbose,vpcid,rtable_externalid))
        subnetid=@aws.ec2.subnet.id_by_cidrblock(region,nil,verbose,vpcid,cidrblock)
		val = ((not subnetid.nil?) and (rtable["RouteTables"].count == 1) and (rtable["RouteTables"][0]["Associations"].any? { |x| x["SubnetId"]=="#{subnetid}"}))
		rtassocid= (val and rtable["RouteTables"].count == 1) ? (rtable["RouteTables"][0]["Associations"].select { |x| x["SubnetId"]=="#{subnetid}"})[0]["RouteTableAssociationId"] : nil
		rtableid = (rtable["RouteTables"].count == 1) ? rtable["RouteTables"][0]["RouteTableId"] : nil
		textout.puts val.to_s if textout
		return val, subnetid, rtableid, rtassocid
	  end

	  def assoc_subnet(region,textout=nil,verbose=nil,vpcid,routetable,cidrblock,nagios,ufile)
        if ufile 
		  ZAWS::Helper::ZFile.prepend("zaws route_table delete_assoc_subnet #{routetable} #{cidrblock} --region #{region} --vpcid #{vpcid} $XTRA_OPTS",'#Delete route table association to subnet',ufile)
		end
		assoc_exists, subnetid, rtableid, rtassocid = subnet_assoc_exists(region,nil,verbose,vpcid,routetable,cidrblock) 
		return ZAWS::Helper::Output.binary_nagios_check(assoc_exists,"OK: Route table association to subnet exists.","CRITICAL: Route table association to subnet does not exist.",textout) if nagios
		if not assoc_exists
		  comline="aws --region #{region} ec2 associate-route-table --subnet-id #{subnetid} --route-table-id #{rtableid}"
		  assocreturn=JSON.parse(@shellout.cli(comline,verbose))
		  textout.puts "Route table associated to subnet." if assocreturn["AssociationId"] 
		else
		  textout.puts "Route table already associated to subnet. Skipping association."
		end
		return 0
	  end

	  def delete_assoc_subnet(region,textout=nil,verbose=nil,vpcid,rtable_externalid,cidrblock)
		assoc_exists, subnetid, rtableid, rtassocid = subnet_assoc_exists(region,nil,verbose,vpcid,rtable_externalid,cidrblock) 
        if assoc_exists
		  comline="aws --region #{region} ec2 disassociate-route-table --association-id #{rtassocid}"
		  assocreturn=JSON.parse(@shellout.cli(comline,verbose))
		  textout.puts "Route table association to subnet deleted." if assocreturn["return"]  == "true"
		else
		  textout.puts "Route table association to subnet not deleted because it does not exist."
		end
	  end

      def propagation_exists_from_gateway(region,textout=nil,verbose=nil,vpcid,rtable_externalid,vgatewayid)
        rtable=JSON.parse(view(region,'json',nil,verbose,vpcid,rtable_externalid))
		val = ((rtable["RouteTables"].count == 1) and (rtable["RouteTables"][0]["PropagatingVgws"].any? { |x| x["GatewayId"]=="#{vgatewayid}"}))
        rtableid = (rtable["RouteTables"].count == 1) ? rtable["RouteTables"][0]["RouteTableId"] : nil
		textout.puts val.to_s if textout
		return val, rtableid
	  end

	  def declare_propagation_from_gateway(region,textout=nil,verbose=nil,vpcid,routetable,vgatewayid,nagios,ufile)
        if ufile 
		  ZAWS::Helper::ZFile.prepend("zaws route_table delete_propagation_from_gateway my_route_table vgw-???????? --region us-west-1 --vpcid my_vpc_id $XTRA_OPTS",'#Delete route propagation',ufile)
		end
		propagation_exists,rtableid = propagation_exists_from_gateway(region,nil,verbose,vpcid,routetable,vgatewayid) 
		return ZAWS::Helper::Output.binary_nagios_check(propagation_exists,"OK: Route propagation from gateway enabled.","CRITICAL: Route propagation from gateway not enabled.",textout) if nagios
		if not propagation_exists
		  comline="aws --region #{region} ec2 enable-vgw-route-propagation --route-table-id #{rtableid} --gateway-id #{vgatewayid}"
		  propreturn=JSON.parse(@shellout.cli(comline,verbose))
		  textout.puts "Route propagation from gateway enabled." if propreturn["return"] == "true"
		else
		  textout.puts "Route propagation from gateway already enabled. Skipping propagation."
		end
		return 0
	  end

      def delete_propagation_from_gateway(region,textout=nil,verbose=nil,vpcid,rtable_externalid,vgatewayid)
        propagation_exists,rtableid = propagation_exists_from_gateway(region,nil,verbose,vpcid,rtable_externalid,vgatewayid) 
        if propagation_exists
		  comline="aws --region #{region} ec2 disable-vgw-route-propagation --route-table-id #{rtableid} --gateway-id #{vgatewayid}"
		  assocreturn=JSON.parse(@shellout.cli(comline,verbose))
		  textout.puts "Deleted route propagation from gateway." if assocreturn["return"]  == "true"
		else
		  textout.puts "Route propagation from gateway does not exist, skipping deletion."
		end
	  end

	end
  end
end

