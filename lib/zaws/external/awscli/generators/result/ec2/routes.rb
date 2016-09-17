module ZAWS
  class External
    class AWSCLI
      class Generators
        class Result
          class EC2
            class Routes
              def initialize
                @route= {}
                @route["Routes"]= []
                self
              end

              def instance_id(route_number, id)
                resize_route_array(route_number)
                @route["Routes"][route_number]["InstanceId"]=id
                self
              end

              def gateway_id(route_number, id)
                resize_route_array(route_number)
                @route["Routes"][route_number]["GatewayId"]=id
                self
              end

              def destination_cidr_block(route_number, cidr)
                resize_route_array(route_number)
                @route["Routes"][route_number]["DestinationCidrBlock"]=cidr
                self
              end

              def resize_route_array(index)
                while index > @route["Routes"].length-1
                  @route["Routes"].push({})
                end
              end

              def add(route)
                @route["Routes"].concat(route.get_route_array)
                self
              end

              def get_json
                @route.to_json
              end

              def get_route_array
                @route["Routes"]
              end

            end
          end
        end
      end
    end
  end
end

