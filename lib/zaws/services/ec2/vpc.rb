require 'json'
require 'netaddr'
require 'timeout'

module ZAWS
  module Services
    module EC2
      class VPC

        def initialize(shellout, aws,undofile)
          @shellout=shellout
          @aws=aws
          @undofile=undofile
          @undofile ||= ZAWS::Helper::ZFile.new
        end

        def view(region, view, textout=nil, verbose=nil)
          @aws.awscli.command_ec2.describeVPCs.execute(region, view, {},verbose)
          textout.puts @aws.awscli.data_ec2.vpc.view
        end

        def view_peering(region, view, textout=nil, verbose=nil)
          @aws.awscli.command_ec2.describeVpcPeeringConnections.execute(region, view, {},verbose)
          textout.puts @aws.awscli.data_ec2.vpc.view
        end

        def check_management_data(region, textout,verbose=nil,profile=nil)
          @aws.awscli.command_ec2.describeVPCs.execute(region, 'json',{}, verbose,profile)
          hash_vpc_name_externalid_data = @aws.awscli.data_ec2.vpc.hash_vpc_name_externalid
          hash_vpc_name_externalid_data.each do |id,vpc|
            if vpc['externalid']=='null'
              textout.puts("FAIL: VPC '#{id}' does not have the tag 'externalid' required to manage vpc with ZAWS.")
            end
            if vpc['Name']=='null'
              textout.puts("WARNING: VPC '#{id}' does not have the tag 'Name' which usually assists humans.")
            end
          end
        end

        def declare(region,cidr,externalid,availabilitytimeout,textout,verbose=nil,profile=nil)
          @aws.awscli.command_ec2.describeVPCs.execute(region, 'json',{}, verbose,profile)
          vpc_exists = @aws.awscli.data_ec2.vpc.exists(cidr,externalid)
          if vpc_exists
            ZAWS::Helper::Output.out_no_op(textout, "No action needed. VPC exists already.")
            return 0
          end
          @aws.awscli.command_ec2.createVPC.execute(region,'json',cidr,textout,verbose,profile)
          vpc_id = @aws.awscli.data_ec2.vpc.id
          @aws.awscli.command_ec2.createTags.execute(vpc_id, region, 'externalid', externalid, textout, verbose)
          @aws.awscli.command_ec2.createTags.execute(vpc_id, region, 'Name', externalid, textout, verbose)
          begin
            filters={ "tag:externalid" => "#{externalid}","vpc-id"=>"#{vpc_id}","cidr"=>"#{cidr}" }
            Timeout.timeout(availabilitytimeout) do
              until @aws.awscli.data_ec2.vpc.available
                sleep(1)
                @aws.awscli.command_ec2.describeVPCs.execute(region, 'json',filters , verbose, profile)
              end
            end
            ZAWS::Helper::Output.out_change(textout, "VPC created.")
          rescue Timeout::Error
            throw 'Timeout before Subnet made available.'
          end

          0
        end
      end
    end
  end
end

