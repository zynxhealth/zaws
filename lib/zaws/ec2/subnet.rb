require 'json'
require 'netaddr'
require 'timeout'

module ZAWS
  module EC2Services
	class Subnet 

	  def initialize(shellout,aws)
		@shellout=shellout
		@aws=aws
	  end

	  def view(region,view,textout=nil,verbose=nil,vpcid=nil,cidrblock=nil)
		filters = {}
		filters["vpc-id"] = "#{vpcid}" if vpcid 
        filters["cidr"] = "#{cidrblock}" if vpcid 
		@aws.awscli.command_ec2.DescribeSubnet.execute(region,view,filters,textout,verbose)
		@aws.awscli.data_ec2.subnet.view()
	  end

	  def id_by_ip(region,textout=nil,verbose=nil,vpcid,ip)
		subnets=JSON.parse(view(region,'json',nil,verbose,vpcid))
		subnet_id=nil
		subnets["Subnets"].each { |x| subnet_id = x["SubnetId"] if (NetAddr::CIDR.create(x["CidrBlock"])).contains?(ip) }
		textout.puts subnet_id if textout
		return subnet_id
	  end

	  def id_by_cidrblock(region,textout=nil,verbose=nil,vpcid,cidrblock)
		subnets=JSON.parse(view(region,'json',nil,verbose,vpcid,cidrblock))
		subnet_id= subnets["Subnets"].count == 1 ? subnets["Subnets"][0]["SubnetId"] : nil
		textout.puts subnet_id if textout
		return subnet_id
	  end

      def id_array_by_cidrblock_array(region,textout=nil,verbose=nil,vpcid,cidrblock_array)
		return cidrblock_array.map {|x| id_by_cidrblock(region,nil,verbose,vpcid,x)}
	  end

	  def exists(region,textout=nil,verbose=nil,vpcid,cidrblock)
		val = id_by_cidrblock(region,nil,verbose,vpcid,cidrblock) ? true : false
		textout.puts val.to_s if textout
		return val 
	  end

	  def declare(region,vpcid,cidrblock,availabilityzone,statetimeout,textout=nil,verbose=nil,nagios=false,ufile=nil)

		subnet_exists=exists(region,nil,verbose,vpcid,cidrblock) 

        if ufile
          ZAWS::Helper::ZFile.prepend("zaws subnet delete #{cidrblock} #{vpcid} --region #{region} $XTRA_OPTS",'#Delete subnet',ufile)
		end
	
		if nagios
           if not subnet_exists
			 ZAWS::Helper::Output.out_nagios_critical(textout,"CRITICAL: Subnet Does Not Exist.")
			 return 2
		   else
		     ZAWS::Helper::Output.out_nagios_ok(textout,"OK: Subnet Exists.")
		   	 return 0
           end
		end

		if subnet_exists
          ZAWS::Helper::Output.out_no_op(textout,"No action needed. Subnet exists already.")
		  return 0
        end

		@aws.awscli.command_ec2.CreateSubnet.execute(region,vpcid,cidrblock,availabilityzone,verbose)
		begin
		  Timeout.timeout(statetimeout) do
			until @aws.awscli.data_ec2.subnet.available()
			  sleep(1)
			  @aws.awscli.command_ec2.DescribeSubnet.execute(region,vpcid,cidrblock,verbose)
			end
		  end
		  ZAWS::Helper::Output.out_change(textout, "Subnet created.")
		rescue Timeout::Error
		  throw 'Timeout before Subnet made available.'
		end
		
		return 0

	  end

	  def available(subnet,verbose)
		#based on the structure of the return from create-subnet and describe-subnet determine if subnet is available
		subnet_hash=JSON.parse(subnet)
		if subnet_hash["Subnet"]
		  return (subnet_hash["Subnet"]["State"] == "available")
		end
		if subnet_hash["Subnets"] and subnet_hash["Subnets"].count == 1
		  return (subnet_hash["Subnets"][0]["State"] == "available")
		end
		return false
	  end

	  def delete(region,textout=nil,verbose=nil,vpcid,cidrblock)
        subnetid=id_by_cidrblock(region,nil,verbose,vpcid,cidrblock)
		if subnetid 
		  comline="aws --region #{region} ec2 delete-subnet --subnet-id #{subnetid}"
          val=JSON.parse(@shellout.cli(comline,verbose))
		  ZAWS::Helper::Output.out_change(textout,"Subnet deleted.") if val["return"] == "true"
		else
		  ZAWS::Helper::Output.out_no_op(textout,"Subnet does not exist. Skipping deletion.")
		end
	  end

	end
  end
end

