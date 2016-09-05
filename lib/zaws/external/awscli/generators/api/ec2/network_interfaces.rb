module ZAWS
  class External
    class AWSCLI
      class Generators
        class API
          class EC2
            class NetworkInterfaces
              def initialize
                @net= {}
                @net["NetworkInterfaces"]= []
                self
              end

              def add_group(network_interface_number, group)
                resize_network_interface_array(network_interface_number)
                if not @net["NetworkInterfaces"][network_interface_number]["Groups"]
                  @net["NetworkInterfaces"][network_interface_number]["Groups"] = []
                end
                @net["NetworkInterfaces"][network_interface_number]["Groups"] << group
                self
              end

              def private_ip_address(network_interface_number, ip)
                resize_network_interface_array(network_interface_number)
                @net["NetworkInterfaces"][network_interface_number]["PrivateIpAddress"] = ip
                self
              end

              def device_index(network_interface_number, index)
                resize_network_interface_array(network_interface_number)
                @net["NetworkInterfaces"][network_interface_number]["DeviceIndex"] = index
                self
              end

              def subnet_id(network_interface_number, id)
                resize_network_interface_array(network_interface_number)
                @net["NetworkInterfaces"][network_interface_number]["SubnetId"] = id
                self
              end

              def resize_network_interface_array(index)
                while index > @net["NetworkInterfaces"].length-1
                  @net["NetworkInterfaces"].push({})
                end
              end

              def get_json
                @net.to_json
              end

              def get_network_interfaces_array
                @net["NetworkInterfaces"]
              end

              def get_network_interfaces_array_to_json
                @net["NetworkInterfaces"].to_json
              end

            end
          end
        end
      end
    end
  end
end
