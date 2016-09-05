module ZAWS
  class External
    class AWSCLI
      class Generators
        class Result
          class EC2
            class NetworkInterfaces
              def initialize
                @net= {}
                @net["NetworkInterfaces"]= []
                self
              end

              def network_interface_id(network_interface_number, id)
                resize_network_interface_array(network_interface_number)
                @net["NetworkInterfaces"][network_interface_number]["NetworkInterfaceId"]=id
                self
              end

              def groups(network_interface_number, groups)
                resize_network_interface_array(network_interface_number)
                @net["NetworkInterfaces"][network_interface_number]["Groups"]=groups.get_security_groups_array
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

            end
          end
        end
      end
    end
  end
end

