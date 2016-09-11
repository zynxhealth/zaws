module ZAWS
  class AWSCLI
    class Data
      class EC2
        class Subnet

          def initialize(shellout, ec2)
            @shellout=shellout
            @ec2=ec2
            @subnet_hash=nil
          end

          def validJSON
            return (@subnet_hash.nil?)
          end

          def load(command, data,verbose)
            @subnet_raw_data = data
            verbose.puts(@subnet_raw_data) if verbose
            @subnet_hash=nil
            begin
              @subnet_hash =JSON.parse(data)
            rescue JSON::ParserError => e
            end
          end

          def view()
            return @subnet_raw_data
          end

          def available()
            if @subnet_hash and @subnet_hash["Subnet"]
              return (@subnet_hash["Subnet"]["State"] == "available")
            end
            if @subnet_hash and @subnet_hash["Subnets"] and @subnet_hash["Subnets"].count == 1
              return (@subnet_hash["Subnets"][0]["State"] == "available")
            end
            return false
          end

          def id_by_ip(ip,verbose=nil)
            return nil if not @subnet_hash["Subnets"]
            subnet_id=nil
            @subnet_hash["Subnets"].each { |x| subnet_id = x["SubnetId"] if (NetAddr::CIDR.create(x["CidrBlock"])).contains?(ip) }
            verbose.puts subnet_id if verbose
            return subnet_id
          end

          def id_by_cidrblock(verbose=nil)
            return nil if not @subnet_hash["Subnets"]
            subnet_id= @subnet_hash["Subnets"].count == 1 ? @subnet_hash["Subnets"][0]["SubnetId"] : nil
            verbose.puts subnet_id if verbose
            return subnet_id
          end
        end
      end
    end
  end
end
