module ZAWS
  class AWSCLI
    class Data
      class EC2
        class VPC

          def initialize(shellout, ec2)
            @shellout=shellout
            @ec2=ec2
            @vpc_hash=nil
          end

          def validJSON
            return (not @vpc_hash.nil?)
          end

          def load(command, data, verbose)
            @vpc_raw_data = data
            @vpc_hash=nil
            begin
              @vpc_hash =JSON.parse(data)
            rescue JSON::ParserError => e
            end
          end

          def view()
            return @vpc_raw_data
          end

          def hash_vpc_name_externalid()
            vpc_name_externalid={}
            if validJSON
              @vpc_hash['Vpcs'].each do |vpc|
                vals={}
                vals['externalid']="null"
                vals['Name']="null"
                vpc['Tags'].each do |tag|
                  vals['Name']=tag['Value'] if tag['Key']=='Name'
                  vals['externalid']=tag['Value'] if tag['Key']=='externalid'
                end
                vpc_name_externalid[vpc['VpcId']]=vals
              end
            end
            return vpc_name_externalid
          end

          def exists(cidr,externalid)
            result = false
            if validJSON
              @vpc_hash['Vpcs'].each do |vpc|
                if result
                  break
                elsif vpc['Tags']
                  vpc['Tags'].each do |tag|
                    result = tag['Key']=='externalid' ? (externalid==tag['Value']) : false
                  end
                  result = (result and (vpc['CidrBlock']==cidr))
                end
              end
            end
            result
          end

          def available()
            if @vpc_hash and @vpc_hash["Vpc"]
              return (@vpc_hash["Vpc"]["State"] == "available")
            end
            if @vpc_hash and @vpc_hash["Vpcs"] and @vpc_hash["Vpcs"].count==1
              return (@vpc_hash["Vpcs"][0]["State"]=="available")
            end
            false
          end

          def id()
            if @vpc_hash and @vpc_hash["Vpc"]
              return (@vpc_hash["Vpc"]["VpcId"])
            end
            0
          end

        end
      end
    end
  end
end
