require 'json'
require 'netaddr'
require 'timeout'

module ZAWS
  module Services
    module ELB
      class LoadBalancer

        def initialize(shellout, aws, undofile)
          @shellout=shellout
          @aws=aws
          @undofile=undofile
          @undofile ||= ZAWS::Helper::ZFile.new
        end

        def view(region, view, textout=nil, verbose=nil)
          comline="aws --output #{view} --region #{region} elb describe-load-balancers"
          lbs=@shellout.cli(comline, verbose)
          textout.puts(lbs) if textout
          return lbs
        end

        def exists(region, lbname, textout=nil, verbose=nil)
          lbs=JSON.parse(view(region, 'json', nil, verbose))
          val = lbs["LoadBalancerDescriptions"].any? { |x| x["LoadBalancerName"]=="#{lbname}" }
          instances = val ? (lbs["LoadBalancerDescriptions"].select { |x| x["LoadBalancerName"]=="#{lbname}" })[0]["Instances"] : nil
          ldescriptions = val ? (lbs["LoadBalancerDescriptions"].select { |x| x["LoadBalancerName"]=="#{lbname}" })[0]["ListenerDescriptions"] : nil
          textout.puts(val.to_s) if textout
          return val, instances, ldescriptions
        end

        def calculated_listener(lbprotocol, lbport, inprotocol, inport, sslcert=nil)
          listeners = []
          single_listener = {}
          single_listener["Protocol"]="#{lbprotocol}"
          single_listener["LoadBalancerPort"]=lbport.to_i
          single_listener["InstanceProtocol"]="#{inprotocol}"
          single_listener["InstancePort"]=inport.to_i
          single_listener["SSLCertificateId"]="#{sslcert}" if sslcert
          listeners << single_listener
          return listeners.to_json
        end

        def create_in_subnet(region, lbname, lbprotocol, lbport, inprotocol, inport, securitygroup, cidrblocks, vpcid, nagios=false, textout=nil, verbose=nil, ufile=nil)
          if ufile
            @undofile.prepend("zaws load_balancer delete #{lbname} --region #{region} $XTRA_OPTS", '#Delete load balancer', ufile)
          end
          lbexists, instances, ldescriptions=exists(region, lbname, nil, verbose)
          return ZAWS::Helper::Output.binary_nagios_check(lbexists, "OK: Load Balancer Exists.", "CRITICAL: Load Balancer does not exist.", textout) if nagios
          if not lbexists
            comline="aws --region #{region} elb create-load-balancer"
            comline+=" --load-balancer-name #{lbname}"
            comline+=" --listeners '#{calculated_listener(lbprotocol, lbport, inprotocol, inport)}'"
            comline+=" --subnets #{@aws.ec2.subnet.id_array_by_cidrblock_array(region,  nil, vpcid, cidrblocks).join(" ")}"
            sgroup_exists, sgroupid = @aws.ec2.security_group.exists(region,  nil, vpcid, securitygroup)
            comline+=" --security-groups #{sgroupid}"
            newlb=JSON.parse(@shellout.cli(comline, verbose))
            ZAWS::Helper::Output.out_change(textout, "Load balancer created.") if newlb["DNSName"]
          else
            ZAWS::Helper::Output.out_no_op(textout, "Load balancer already exists. Skipping creation.")
          end
          exit 0
        end

        def delete(region, lbname, textout=nil, verbose=nil)
          lbexists, instances, ldescriptions=exists(region, lbname, nil, verbose)
          if lbexists
            comline="aws --region #{region} elb delete-load-balancer"
            comline+=" --load-balancer-name #{lbname}"
            deletelb=JSON.parse(@shellout.cli(comline, verbose))
            ZAWS::Helper::Output.out_change(textout, "Load balancer deleted.") if deletelb["return"] == "true"
          else
            ZAWS::Helper::Output.out_no_op(textout, "Load balancer does not exist. Skipping deletion.")
          end
        end

        def exists_instance(region, lbname, instance_external_id, vpcid, textout=nil, verbose=nil)
          lbexists, instances, ldescriptions=exists(region, lbname, nil, verbose)
          instance_exists, instance_id = @aws.ec2.compute.exists(region, nil, verbose, vpcid, instance_external_id)
          val = (lbexists and instance_exists and (instances.any? { |x| x["InstanceId"]==instance_id }))
          textout.puts(val.to_s) if textout
          return val, instance_id
        end

        def register_instance(region, lbname, instance_external_id, vpcid, nagios=false, textout=nil, verbose=nil, ufile=nil)
          if ufile
            @undofile.prepend("zaws load_balancer deregister_instance #{lbname} #{instance_external_id} --region #{region} --vpcid my_vpc_id $XTRA_OPTS", '#Deregister instance', ufile)
          end
          instance_registered, instance_id = exists_instance(region, lbname, instance_external_id, vpcid, nil, verbose)
          return ZAWS::Helper::Output.binary_nagios_check(instance_registered, "OK: Instance registerd.", "CRITICAL: Instance not registered.", textout) if nagios
          if not instance_registered
            comline="aws --region #{region} elb register-instances-with-load-balancer"
            comline+=" --load-balancer-name #{lbname}"
            comline+=" --instances #{instance_id}"
            newinstance=JSON.parse(@shellout.cli(comline, verbose))
            ZAWS::Helper::Output.out_change(textout, "New instance registered.") if newinstance["Instances"]
          else
            ZAWS::Helper::Output.out_no_op(textout, "Instance already registered. Skipping registration.")
          end
        end

        def deregister_instance(region, lbname, instance_external_id, vpcid, textout=nil, verbose=nil)
          instance_registered, instance_id = exists_instance(region, lbname, instance_external_id, vpcid, nil, verbose)
          if instance_registered
            comline="aws --region #{region} elb deregister-instances-with-load-balancer"
            comline+=" --load-balancer-name #{lbname}"
            comline+=" --instances #{instance_id}"
            newinstance=JSON.parse(@shellout.cli(comline, verbose))
            verbose.puts "DEBUG: newinstance=#{newinstance} TODO: need to know if it is returning a json object with a return key." if verbose
            ZAWS::Helper::Output.out_change(textout, "Instance deregistered.") if newinstance["return"] == "true"
          else
            ZAWS::Helper::Output.out_no_op(textout, "Instance not registered. Skipping deregistration.")
          end
        end

        def exists_listener(region, lbname, lbprotocol, lbport, inprotocol, inport, textout=nil, verbose=nil)
          lbexists, instances, ldescriptions=exists(region, lbname, nil, verbose)
          verbose.puts ldescriptions if verbose
          val = (lbexists and (ldescriptions.any? { |x| x["Listener"]["LoadBalancerPort"]==(lbport.to_i) && x["Listener"]["Protocol"]==lbprotocol && x["Listener"]["InstancePort"]==(inport.to_i) && x["Listener"]["InstanceProtocol"]==inprotocol }))
          textout.puts(val.to_s) if textout
          return val
        end

        def declare_listener(region, lbname, lbprotocol, lbport, inprotocol, inport, nagios=false, textout=nil, verbose=nil, ufile=nil)
          if ufile
            @undofile.prepend("zaws load_balancer delete_listener #{lbname} #{lbprotocol} #{lbport} #{inprotocol} #{inport} --region #{region} $XTRA_OPTS", '#Delete listener', ufile)
          end
          lexists=exists_listener(region, lbname, lbprotocol, lbport, inprotocol, inport, nil, verbose)
          return ZAWS::Helper::Output.binary_nagios_check(lexists, "OK: Listerner exists.", "CRITICAL: Listener does not exist.", textout) if nagios
          if not lexists
            comline="aws --region #{region} elb create-load-balancer-listeners"
            comline+=" --load-balancer-name #{lbname}"
            comline+=" --listeners '#{calculated_listener(lbprotocol, lbport, inprotocol, inport)}'"
            @shellout.cli(comline, verbose)
            verbose.puts "DEBUG: There is no return value, unnormal." if verbose
            ZAWS::Helper::Output.out_change(textout, "Listener created.")
          else
            ZAWS::Helper::Output.out_no_op(textout, "Listerner exists. Skipping creation.")
          end
        end

        def delete_listener(region, lbname, lbprotocol, lbport, inprotocol, inport, textout=nil, verbose=nil)
          lexists=exists_listener(region, lbname, lbprotocol, lbport, inprotocol, inport, nil, verbose)
          if lexists
            comline="aws --region #{region} elb delete-load-balancer-listeners"
            comline+=" --load-balancer-name #{lbname}"
            comline+=" --load-balancer-ports '#{lbport}'"
            dellistener=JSON.parse(@shellout.cli(comline, verbose))
            verbose.puts "DEBUG: newinstance=#{dellistener} TODO: need to know if it is returning a json object with a return key." if verbose
            ZAWS::Helper::Output.out_change(textout, "Listerner deleted.") if dellistener["return"] == "true"
          else
            ZAWS::Helper::Output.out_no_op(textout, "Listener does not exist. Skipping deletion.")
          end
        end

      end
    end
  end
end
