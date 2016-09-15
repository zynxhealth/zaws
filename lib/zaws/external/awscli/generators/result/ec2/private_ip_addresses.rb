module ZAWS
  class External
    class AWSCLI
      class Generators
        class Result
          class EC2
            class PrivateIpAddresses
              def initialize
                @ips= {}
                @ips["PrivateIpAddresses"]= []
                self
              end

              def private_ip_address(ip_number, ip)
                resize_ip_array(ip_number)
                @ips["PrivateIpAddresses"][ip_number]["PrivateIpAddress"]=ip
                self
              end

              def resize_ip_array(index)
                while index > @ips["PrivateIpAddresses"].length-1
                  @ips["PrivateIpAddresses"].push({})
                end
              end

              def get_json
                @ips.to_json
              end

              def get_private_ip_addresses_array
                @ips["PrivateIpAddresses"]
              end

            end
          end
        end
      end
    end
  end
end

