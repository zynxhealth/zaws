require 'json'
require 'netaddr'
require 'timeout'

module ZAWS
  module Services
    module EC2
      class Subnet

        def initialize(shellout, aws, undofile=nil)
          @shellout=shellout
          @aws=aws
          @undofile=undofile
          @undofile ||= ZAWS::Helper::ZFile.new
        end

        def view(region, viewtype,  verbose=nil, vpcid=nil, cidrblock=nil)
          ds=@aws.awscli.command_ec2.describeSubnets
          ds.clear_settings
          ds.filter.vpc_id(vpcid).cidr(cidrblock)
          ds.aws.output(viewtype).region(region)
          ds.execute(verbose)
          ds.view
        end

        def declare(region, vpcid, cidrblock, availabilityzone, statetimeout, textout=nil, verbose=nil, check=false, undo_file=nil)
          subnet_exists=exists(region,verbose, vpcid, cidrblock)
          if undo_file
            @undofile.prepend("zaws subnet delete #{cidrblock} #{vpcid} --region #{region} $XTRA_OPTS", '#Delete subnet', undo_file)
          end
          if check
            if not subnet_exists
              ZAWS::Helper::Output.out_nagios_critical(textout, "CRITICAL: Subnet Does Not Exist.")
              return 2
            else
              ZAWS::Helper::Output.out_nagios_ok(textout, "OK: Subnet Exists.")
              return 0
            end
          end
          if subnet_exists
            ZAWS::Helper::Output.out_no_op(textout, "No action needed. Subnet exists already.")
            return 0
          end

          cs=@aws.awscli.command_ec2.createSubnet
          cs.clear_settings
          cs.vpc_id(vpcid).cidr(cidrblock).availability_zone(availabilityzone)
          cs.aws.output("json").region(region)
          cs.execute(verbose)

          begin
            Timeout.timeout(statetimeout) do
              until @aws.awscli.command_ec2.createSubnet.available or @aws.awscli.command_ec2.describeSubnets.available
                sleep(1)
                view(region, 'json', verbose, vpcid, cidrblock)
              end
            end
            ZAWS::Helper::Output.out_change(textout, "Subnet created.")
          rescue Timeout::Error
            throw 'Timeout before Subnet made available.'
          end
          return 0
        end

        def delete(region, textout=nil, verbose=nil, vpcid, cidrblock)
          subnetid=id_by_cidrblock(region, verbose, vpcid, cidrblock)
          if not subnetid
            ZAWS::Helper::Output.out_no_op(textout, "Subnet does not exist. Skipping deletion.")
            return 0
          end

          cs=@aws.awscli.command_ec2.deleteSubnet
          cs.clear_settings
          cs.subnet_id(subnetid)
          cs.aws.region(region)
          val=JSON.parse(cs.execute(verbose))
          ZAWS::Helper::Output.out_change(textout, "Subnet deleted.") if val["return"] == "true"
        end

        # def available(subnet, verbose)
        #   #based on the structure of the return from create-subnet and describe-subnet determine if subnet is available
        #   subnet_hash=JSON.parse(subnet)
        #   return (subnet_hash["Subnet"]["State"] == "available") if subnet_hash["Subnet"]
        #   return (subnet_hash["Subnets"][0]["State"] == "available") if subnet_hash["Subnets"] and subnet_hash["Subnets"].count == 1
        #   return false
        # end

        def id_by_ip(region,  verbose=nil, vpcid, ip)
          view(region, 'json', verbose, vpcid)
          return @aws.awscli.command_ec2.describeSubnets.id_by_ip(ip)
        end

        def id_by_cidrblock(region, verbose=nil, vpcid, cidrblock)
          view(region, 'json', verbose, vpcid, cidrblock)
          return @aws.awscli.command_ec2.describeSubnets.id_by_cidrblock(verbose)
        end

        def id_array_by_cidrblock_array(region,  verbose=nil, vpcid, cidrblock_array)
          return cidrblock_array.map { |x| id_by_cidrblock(region, verbose, vpcid, x) }
        end

        def exists(region, verbose=nil, vpcid, cidrblock)
          val = id_by_cidrblock(region, verbose, vpcid, cidrblock) ? true : false
          verbose.puts val.to_s if verbose
          return val
        end

      end
    end
  end
end
