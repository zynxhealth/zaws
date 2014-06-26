require 'json'
require 'netaddr'
require 'timeout'

module ZAWS
  module EC2Services
	class SecurityGroup 

	  def initialize(shellout,aws)
		@shellout=shellout
		@aws=aws
	  end

	  def view(region,view,textout=nil,verbose=nil,vpcid=nil,groupname=nil,groupid=nil,perm_groupid=nil,perm_protocol=nil,perm_toport=nil,cidr=nil)
		comline="aws --output #{view} --region #{region} ec2 describe-security-groups"
		if vpcid || groupname
		  comline = comline + " --filter"
		end
		comline = comline + " 'Name=vpc-id,Values=#{vpcid}'" if vpcid 
		comline = comline + " 'Name=group-name,Values=#{groupname}'" if groupname
        comline = comline + " 'Name=group-id,Values=#{groupid}'" if groupid
        comline = comline + " 'Name=ip-permission.group-id,Values=#{perm_groupid}'" if perm_groupid
        comline = comline + " 'Name=ip-permission.cidr,Values=#{cidr}'" if cidr 
	    comline = comline + " 'Name=ip-permission.protocol,Values=#{perm_protocol}'" if perm_protocol
        comline = comline + " 'Name=ip-permission.to-port,Values=#{perm_toport}'" if perm_toport
		sgroups=@shellout.cli(comline,verbose)
		textout.puts(sgroups) if textout
		return sgroups
	  end

	  def exists(region,textout=nil,verbose=nil,vpcid,groupname)
		sgroups=JSON.parse(view(region,'json',nil,verbose,vpcid,groupname))
		val = (sgroups["SecurityGroups"].count == 1)
		sgroupid = val ? sgroups["SecurityGroups"][0]["GroupId"] : nil
		textout.puts val.to_s if textout
		return val, sgroupid 
	  end

	  def declare(region,vpcid,groupname,description,nagios,textout=nil,verbose=nil,ufile=nil)
		if ufile
          ZAWS::Helper::File.prepend("zaws security_group delete #{groupname} --region #{region} --vpcid #{vpcid} $XTRA_OPTS",'#Delete security group',ufile)
		end
		sgroup_exists,sgroupid = exists(region,nil,verbose,vpcid,groupname) 
		return ZAWS::Helper::Output.binary_nagios_check(sgroup_exists,"OK: Security Group Exists.","CRITICAL: Security Group Does Not Exist.",textout) if nagios
		if not sgroup_exists
		  comline="aws --output json --region #{region} ec2 create-security-group --vpc-id #{vpcid} --group-name #{groupname} --description '#{description}'"
		  sgroup=JSON.parse(@shellout.cli(comline,verbose))
		  textout.puts "Security Group Created." if sgroup["return"] == "true"
		else
		  textout.puts "Security Group Exists Already. Skipping Creation."
		end
	  end

      def id_by_name(region,textout=nil,verbose=nil,vpcid,groupname)
		sgroups=JSON.parse(view(region,'json',nil,verbose,vpcid,groupname))
		group_id= sgroups["SecurityGroups"].count == 1 ? sgroups["SecurityGroups"][0]["GroupId"] : nil
		raise "More than one security group found when looking up id by name." if sgroups["SecurityGroups"].count > 1 
		textout.puts group_id if textout
		return group_id
	  end

    
	  def delete(region,textout=nil,verbose=nil,vpcid,groupname)
		groupid=id_by_name(region,nil,nil,vpcid,groupname)
		if groupid 
		  comline="aws --region #{region} ec2 delete-security-group --group-ids #{groupid}"
		  sgroup=JSON.parse(@shellout.cli(comline,verbose))
		  textout.puts "Security Group deleted." if sgroup["return"] == "true"
		else
		  textout.puts "Security Group does not exist. Skipping deletion."
		end
	  end

      def ingress_group_exists(region,vpcid,target,source,protocol,port,textout=nil,verbose=nil) 
        targetid=id_by_name(region,nil,nil,vpcid,target)
        sourceid=id_by_name(region,nil,nil,vpcid,source)
        if targetid && sourceid
          sgroups=JSON.parse(view(region,'json',nil,verbose,vpcid,nil,targetid,sourceid,protocol,port))
		  val = (sgroups["SecurityGroups"].count > 0)
          textout.puts val.to_s if textout
		  return val, targetid, sourceid 
		end
	  end

	  def ingress_cidr_exists(region,vpcid,target,cidr,protocol,port,textout=nil,verbose=nil) 
		verbose=$stdout
        targetid=id_by_name(region,nil,nil,vpcid,target)
        if targetid 
          sgroups=JSON.parse(view(region,'json',nil,verbose,vpcid,nil,targetid,nil,protocol,port,cidr))
		  val = (sgroups["SecurityGroups"].count > 0)
          textout.puts val.to_s if textout
		  return val, targetid 
		end
	  end

	  def declare_ingress_group(region,vpcid,target,source,protocol,port,nagios,textout=nil,verbose=nil,ufile=nil) 
		if ufile
		  ZAWS::Helper::File.prepend("zaws security_group delete_ingress_group #{target} #{source} #{protocol} #{port} --region #{region} --vpcid #{vpcid} $XTRA_OPTS",'#Delete security group ingress group rule',ufile)
		end
		ingress_exists,targetid,sourceid = ingress_group_exists(region,vpcid,target,source,protocol,port,nil,verbose)
		return ZAWS::Helper::Output.binary_nagios_check(ingress_exists,"OK: Security group ingress group rule exists.","CRITICAL: Security group ingress group rule does not exist.",textout) if nagios
		if not ingress_exists 
          comline="aws --region #{region} ec2 authorize-security-group-ingress --group-id #{targetid} --source-security-group-owner-id #{sourceid} --protocol #{protocol} --port #{port}"
		  ingressrule=JSON.parse(@shellout.cli(comline,verbose))
		  textout.puts "Ingress group rule created." if ingressrule["return"] == "true"
		else
          textout.puts "Ingress group rule not created. Exists already."
		end
		return 0
	  end

	  def declare_ingress_cidr(region,vpcid,target,cidr,protocol,port,nagios,textout=nil,verbose=nil,ufile=nil) 
		if ufile
		  ZAWS::Helper::File.prepend("zaws security_group delete_ingress_cidr #{target} #{cidr} #{protocol} #{port} --region #{region} --vpcid #{vpcid} $XTRA_OPTS",'#Delete cidr ingress group rule',ufile)
		end
		ingress_exists,targetid = ingress_cidr_exists(region,vpcid,target,cidr,protocol,port,nil,verbose)
		return ZAWS::Helper::Output.binary_nagios_check(ingress_exists,"OK: Security group ingress cidr rule exists.","CRITICAL: Security group ingress cidr rule does not exist.",textout) if nagios
		if not ingress_exists 
          comline="aws --region #{region} ec2 authorize-security-group-ingress --group-id #{targetid} --cidr #{cidr} --protocol #{protocol} --port #{port}"
		  ingressrule=JSON.parse(@shellout.cli(comline,verbose))
		  textout.puts "Ingress cidr rule created." if ingressrule["return"] == "true"
		else
          textout.puts "Ingress cidr rule not created. Exists already."
		end
		return 0
	  end

	  def delete_ingress_group(region,vpcid,target,source,protocol,port,textout=nil,verbose=nil) 
		ingress_exists,targetid,sourceid = ingress_group_exists(region,vpcid,target,source,protocol,port,nil,verbose)
		if ingress_exists 
          comline="aws --region #{region} ec2 revoke-security-group-ingress --group-id #{targetid} --source-security-group-owner-id #{sourceid} --protocol #{protocol} --port #{port}"
		  val=JSON.parse(@shellout.cli(comline,verbose))
		  textout.puts "Security group ingress group rule deleted." if val["return"] == "true"
		else
          textout.puts "Security group ingress group rule does not exist. Skipping deletion."
		end
	  end

	  def delete_ingress_cidr(region,vpcid,target,cidr,protocol,port,textout=nil,verbose=nil) 
		ingress_exists,targetid = ingress_cidr_exists(region,vpcid,target,cidr,protocol,port,nil,verbose)
		if ingress_exists 
          comline="aws --region #{region} ec2 revoke-security-group-ingress --group-id #{targetid} --cidr #{cidr} --protocol #{protocol} --port #{port}"
		  val=JSON.parse(@shellout.cli(comline,verbose))
		  textout.puts "Security group ingress cidr rule deleted." if val["return"] == "true"
		else
          textout.puts "Security group ingress cidr rule does not exist. Skipping deletion."
		end
	  end

	 end
  end
end

