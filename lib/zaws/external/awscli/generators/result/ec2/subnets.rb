module ZAWS
  class External
    class AWSCLI
      class Generators
        class Result
          class EC2
            class Subnets
              def initialize
                @subnets= {}
                @subnets["Subnets"]= []
                self
              end

              def vpc_id(subnet_number, vpc_id)
                resize_subnets_array(subnet_number)
                @subnets["Subnets"][subnet_number]["VpcId"]=vpc_id
                self
              end

              def cidr_block(subnet_number, cidr)
                resize_subnets_array(subnet_number)
                @subnets["Subnets"][subnet_number]["CidrBlock"]=cidr
                self
              end

              def map_public_ip_on_launch(subnet_number, cidr)
                resize_subnets_array(subnet_number)
                @subnets["Subnets"][subnet_number]["MapPublicIpOnLaunch"]=cidr
                self
              end

              def default_for_az(subnet_number, default)
                resize_subnets_array(subnet_number)
                @subnets["Subnets"][subnet_number]["DefaultForAz"]=default
                self
              end

              def state(subnet_number, state)
                resize_subnets_array(subnet_number)
                @subnets["Subnets"][subnet_number]["State"]=state
                self
              end

              def available_ip_address_count(subnet_number, count)
                resize_subnets_array(subnet_number)
                @subnets["Subnets"][subnet_number]["AvailableIpAddressCount"]=count
                self
              end

              def subnet_id(subnet_number, id)
                resize_subnets_array(subnet_number)
                @subnets["Subnets"][subnet_number]["SubnetId"]=id
                self
              end

              def resize_subnets_array(index)
                while index > @subnets["Subnets"].length-1
                  @subnets["Subnets"].push({})
                end
              end

              def get_json
                @subnets.to_json
              end

              def get_subnets_array
                @subnets["Subnets"]
              end

            end
          end
        end
      end
    end
  end
end

