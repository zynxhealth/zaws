require 'json'
require 'netaddr'
require 'timeout'

module ZAWS
  module Services
    module EC2
      class SecurityGroup

        def initialize(shellout, aws,undofile)
          @shellout=shellout
          @aws=aws
          @undofile=undofile
          @undofile ||= ZAWS::Helper::ZFile.new
        end

        def view(region, view, verbose=nil, vpcid=nil, groupname=nil, groupid=nil, perm_groupid=nil, perm_protocol=nil, perm_toport=nil, cidr=nil, unused=false)
          ds=@aws.awscli.command_ec2.describeSecurityGroups
          ds.clear_settings
          ds.filter.vpc_id(vpcid).group_name(groupname).group_id(groupid)
          ds.filter.ip_permission_group_id(perm_groupid).ip_permission_cidr(cidr)
          ds.filter.ip_permission_protocol(perm_protocol).ip_permission_to_port(perm_toport)
          ds.aws.output(view).region(region)
          ds.execute(verbose)
          sgroups=ds.view
          if unused
            instances = @aws.ec2.compute.view(region, 'json', nil, verbose)
            sgroups = JSON.parse(filter_groups_by_instances(sgroups, instances))
            sgroups = sgroups['SecurityGroups'].map { |x| x['GroupName'] }.join("\n")
          end
          verbose.puts(sgroups) if verbose
          return sgroups
        end

        def exists(region, verbose=nil, vpcid, groupname)
          view(region, 'json', verbose, vpcid, groupname)
          val, sgroupid = @aws.awscli.command_ec2.describeSecurityGroups.exists
          verbose.puts val.to_s if verbose
          return val, sgroupid
        end

        def filter_groups_by_instances(security_groups, instances)
          security_groups_hash=JSON.parse(security_groups)
          instances_hash=JSON.parse(instances)
          instances_hash['Reservations'][0]['Instances'].each do |x|
            x['SecurityGroups'].each do |y|
              security_groups_hash['SecurityGroups'] = security_groups_hash['SecurityGroups'].select { |j| not j['GroupName'] == (y['GroupName']) }
            end
            x['NetworkInterfaces'].each do |y|
              y['Groups'].each do |z|
                security_groups_hash['SecurityGroups'] = security_groups_hash['SecurityGroups'].select { |j| not j['GroupName'] == (z['GroupName']) }
              end
            end
          end
          JSON.generate(security_groups_hash)
        end


        def declare(region, vpcid, groupname, description, check, textout=nil, verbose=nil, ufile=nil)
          if ufile
            @undofile.prepend("zaws security_group delete #{groupname} --region #{region} --vpcid #{vpcid} $XTRA_OPTS", '#Delete security group', ufile)
          end
          sgroup_exists, sgroupid = exists(region, verbose, vpcid, groupname)
          return ZAWS::Helper::Output.binary_nagios_check(sgroup_exists, "OK: Security Group Exists.", "CRITICAL: Security Group Does Not Exist.", textout) if check
          if not sgroup_exists

            comline="aws --output json --region #{region} ec2 create-security-group --vpc-id #{vpcid} --group-name #{groupname} --description '#{description}'"

            sgroup=JSON.parse(@shellout.cli(comline, verbose))

            ZAWS::Helper::Output.out_change(textout, "Security Group Created.") if sgroup["return"] == "true"
          else
            ZAWS::Helper::Output.out_no_op(textout, "Security Group Exists Already. Skipping Creation.")
          end
          return 0
        end

        def delete(region, verbose=nil, vpcid, groupname)
          groupid=id_by_name(region, nil, nil, vpcid, groupname)
          return ZAWS::Helper::Output.return_no_op("Security Group does not exist. Skipping deletion.") if !groupid
          ds=@aws.awscli.command_ec2.deleteSecurityGroup
          ds.clear_settings
          ds.security_group_id(groupid)
          ds.aws.region(region)
          sgroup=JSON.parse(ds.execute(verbose))
          return ZAWS::Helper::Output.return_change("Security Group deleted.") if sgroup["return"] == "true"
        end

        def id_by_name(region, textout=nil, verbose=nil, vpcid, groupname)
          sgroups=JSON.parse(view(region, 'json', verbose, vpcid, groupname))
          group_id= sgroups["SecurityGroups"].count == 1 ? sgroups["SecurityGroups"][0]["GroupId"] : nil
          raise "More than one security group found when looking up id by name." if sgroups["SecurityGroups"].count > 1
          textout.puts group_id if textout
          return group_id
        end

        def ingress_group_exists(region, vpcid, target, source, protocol, port, textout=nil, verbose=nil)
          targetid=id_by_name(region, nil, nil, vpcid, target)
          sourceid=id_by_name(region, nil, nil, vpcid, source)
          if targetid && sourceid
            sgroups=JSON.parse(view(region, 'json', verbose, vpcid, nil, targetid, sourceid, protocol, port))
            if (sgroups["SecurityGroups"].count > 0)
              # Additionally filter out the sgroups that do not have the source group  and port in the same ip permissions
              sgroups["SecurityGroups"]=sgroups["SecurityGroups"].select { |x| x['IpPermissions'].any? { |y| y['ToPort'] and y['FromPort'] and y['IpProtocol']==protocol and y['ToPort']==port.to_i and y['FromPort']==port.to_i and y['UserIdGroupPairs'].any? { |z| z['GroupId']=="#{sourceid}" } } }
            end
            val = (sgroups["SecurityGroups"].count > 0)
            textout.puts val.to_s if textout
            return val, targetid, sourceid
          end
        end

        def ingress_cidr_exists(region, vpcid, target, cidr, protocol, port, textout=nil, verbose=nil)
          targetid=id_by_name(region, nil, nil, vpcid, target)
          if targetid
            sgroups=JSON.parse(view(region, 'json', verbose, vpcid, nil, targetid, nil, protocol, port, cidr))
            if (sgroups["SecurityGroups"].count > 0)
              # Additionally filter out the sgroups that do not have the cidr and port in the same ip permissions
              sgroups["SecurityGroups"]=sgroups["SecurityGroups"].select { |x| x['IpPermissions'].any? { |y| y['ToPort'] and y['FromPort'] and y['IpProtocol']==protocol and y['ToPort']==port.to_i and y['FromPort']==port.to_i and y['IpRanges'].any? { |z| z['CidrIp']=="#{cidr}" } } }
            end
            val = (sgroups["SecurityGroups"].count > 0)
            textout.puts val.to_s if textout
            return val, targetid
          end
        end

        def declare_ingress_group(region, vpcid, target, source, protocol, port, nagios, textout=nil, verbose=nil, ufile=nil)
          if ufile
            ZAWS::Helper::ZFile.prepend("zaws security_group delete_ingress_group #{target} #{source} #{protocol} #{port} --region #{region} --vpcid #{vpcid} $XTRA_OPTS", '#Delete security group ingress group rule', ufile)
          end
          ingress_exists, targetid, sourceid = ingress_group_exists(region, vpcid, target, source, protocol, port, nil, verbose)
          return ZAWS::Helper::Output.binary_nagios_check(ingress_exists, "OK: Security group ingress group rule exists.", "CRITICAL: Security group ingress group rule does not exist.", textout) if nagios
          if not ingress_exists
            comline="aws --region #{region} ec2 authorize-security-group-ingress --group-id #{targetid} --source-group #{sourceid} --protocol #{protocol} --port #{port}"
            # aws cli not returning json causes error.
            @shellout.cli(comline, verbose)
            ZAWS::Helper::Output.out_change(textout, "Ingress group rule created.")
          else
            ZAWS::Helper::Output.out_no_op(textout, "Ingress group rule not created. Exists already.")
          end
          return 0
        end

        def declare_ingress_cidr(region, vpcid, target, cidr, protocol, port, nagios, textout=nil, verbose=nil, ufile=nil)
          if ufile
            ZAWS::Helper::ZFile.prepend("zaws security_group delete_ingress_cidr #{target} #{cidr} #{protocol} #{port} --region #{region} --vpcid #{vpcid} $XTRA_OPTS", '#Delete cidr ingress group rule', ufile)
          end
          ingress_exists, targetid = ingress_cidr_exists(region, vpcid, target, cidr, protocol, port, nil, verbose)
          return ZAWS::Helper::Output.binary_nagios_check(ingress_exists, "OK: Security group ingress cidr rule exists.", "CRITICAL: Security group ingress cidr rule does not exist.", textout) if nagios
          if not ingress_exists
            comline="aws --region #{region} ec2 authorize-security-group-ingress --group-id #{targetid} --cidr #{cidr} --protocol #{protocol} --port #{port}"
            # aws cli not returning json causes error.
            @shellout.cli(comline, verbose)
            ZAWS::Helper::Output.out_change(textout, "Ingress cidr rule created.")
          else
            ZAWS::Helper::Output.out_no_op(textout, "Ingress cidr rule not created. Exists already.")
          end
          return 0
        end

        def delete_ingress_group(region, vpcid, target, source, protocol, port, textout=nil, verbose=nil)
          ingress_exists, targetid, sourceid = ingress_group_exists(region, vpcid, target, source, protocol, port, nil, verbose)
          if ingress_exists
            comline="aws --region #{region} ec2 revoke-security-group-ingress --group-id #{targetid} --source-group #{sourceid} --protocol #{protocol} --port #{port}"
            val=JSON.parse(@shellout.cli(comline, verbose))
            ZAWS::Helper::Output.out_change(textout, "Security group ingress group rule deleted.") if val["return"] == "true"
          else
            ZAWS::Helper::Output.out_no_op(textout, "Security group ingress group rule does not exist. Skipping deletion.")
          end
        end

        def delete_ingress_cidr(region, vpcid, target, cidr, protocol, port, textout=nil, verbose=nil)
          ingress_exists, targetid = ingress_cidr_exists(region, vpcid, target, cidr, protocol, port, nil, verbose)
          if ingress_exists
            comline="aws --region #{region} ec2 revoke-security-group-ingress --group-id #{targetid} --cidr #{cidr} --protocol #{protocol} --port #{port}"
            val=JSON.parse(@shellout.cli(comline, verbose))
            ZAWS::Helper::Output.out_change(textout, "Security group ingress cidr rule deleted.") if val["return"] == "true"
          else
            ZAWS::Helper::Output.out_no_op(textout, "Security group ingress cidr rule does not exist. Skipping deletion.")
          end
        end

      end
    end
  end
end
