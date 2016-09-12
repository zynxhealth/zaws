require 'json'
require 'netaddr'
require 'timeout'

module ZAWS
  module Services
    module EC2
      class Elasticip

        def initialize(shellout, aws,undofile)
          @shellout=shellout
          @aws=aws
          @undofile=undofile
          @undofile ||= ZAWS::Helper::ZFile.new
        end

        def view(region, view, textout=nil, verbose=nil, vpcid=nil, instanceid=nil)
          comline="aws --output #{view} --region #{region} ec2 describe-addresses"
          if vpcid or instanceid
            comline = comline + " --filter"
          end
          comline = comline + " 'Name=domain,Values=vpc'" if vpcid
          comline = comline + " 'Name=instance-id,Values=#{instanceid}'" if instanceid
          rtables=@shellout.cli(comline, verbose)
          textout.puts(rtables) if textout
          return rtables
        end

        def assoc_exists(region, externalid, textout=nil, verbose=nil, vpcid=nil)
          val, instance_id, sgroups=@aws.ec2.compute.exists(region, nil, verbose, vpcid, externalid)
          if val
            addresses=JSON.parse(view(region, 'json', nil, verbose, vpcid, instance_id))
            addressassoc=(addresses["Addresses"] and (addresses["Addresses"].count == 1))
            associationid= (addressassoc and addresses["Addresses"][0]["AssociationId"]) ? addresses["Addresses"][0]["AssociationId"] : nil
            allocationid= (addressassoc and addresses["Addresses"][0]["AllocationId"]) ? addresses["Addresses"][0]["AllocationId"] : nil
            ip= (addressassoc and addresses["Addresses"][0]["PublicIp"]) ? addresses["Addresses"][0]["PublicIp"] : nil
            textout.puts addressassoc if textout
            return addressassoc, instance_id, associationid, allocationid, ip
          else
            textout.puts addressassoc if textout
            return false, nil, nil, nil, nil
          end
        end

        def declare(region, externalid, textout=nil, verbose=nil, vpcid=nil, nagios=nil, ufile=nil)
          if ufile
            @undofile.prepend("zaws elasticip release #{externalid} --region #{region} --vpcid #{vpcid} $XTRA_OPTS", '#Release elastic ip.', ufile)
          end
          elasticip_exists, instance_id, association_id, allocation_id, ip=assoc_exists(region, externalid, nil, verbose, vpcid)
          return ZAWS::Helper::Output.binary_nagios_check(elasticip_exists, "OK: Elastic Ip exists.", "CRITICAL: Elastic Ip DOES NOT EXIST.", textout) if nagios
          if not elasticip_exists and instance_id
            comline="aws --region #{region} ec2 allocate-address --domain vpc"
            allocation=JSON.parse(@shellout.cli(comline, verbose))
            if allocation["AllocationId"]
              comline="aws --region #{region} ec2 associate-address --instance-id #{instance_id} --allocation-id #{allocation["AllocationId"]}"
              association=JSON.parse(@shellout.cli(comline, verbose))
              ZAWS::Helper::Output.out_change(textout, "New elastic ip associated to instance.") if association["AssociationId"]
            end
          else
            ZAWS::Helper::Output.out_no_op(textout, "instance already has an elastic ip. Skipping creation.")
          end
        end

        def release(region, externalid, textout=nil, verbose=nil, vpcid=nil)
          elasticip_exists, instance_id, association_id, allocation_id, ip=assoc_exists(region, externalid, nil, verbose, vpcid)
          if elasticip_exists and association_id and allocation_id
            comline="aws --region #{region} ec2 disassociate-address --association-id #{association_id}"
            disassociation=JSON.parse(@shellout.cli(comline, verbose))
            if disassociation["return"]=="true"
              comline="aws --region #{region} ec2 release-address --allocation-id #{allocation_id}"
              release=JSON.parse(@shellout.cli(comline, verbose))
              ZAWS::Helper::Output.out_change(textout, "Deleted elasticip.") if release["return"] == "true"
            end
          else
            ZAWS::Helper::Output.out_no_op(textout, "Elasticip does not exist. Skipping deletion.")
          end
        end

      end
    end
  end
end
