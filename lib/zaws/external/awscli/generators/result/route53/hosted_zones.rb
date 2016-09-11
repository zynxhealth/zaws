module ZAWS
  class External
    class AWSCLI
      class Generators
        class Result
          class Route53
            class HostedZones
              def initialize
                @hostedZones= {}
                @hostedZones["HostedZones"]= []
                self
              end

              def id(hosted_zone_number, id)
                resize_hostedZones_array(hosted_zone_number)
                @hostedZones["HostedZones"][hosted_zone_number]["Id"]=id
                self
              end

              def name(hosted_zone_number, name)
                resize_hostedZones_array(hosted_zone_number)
                @hostedZones["HostedZones"][hosted_zone_number]["Name"]=name
                self
              end

              def resize_hostedZones_array(index)
                while index > @hostedZones["HostedZones"].length-1
                  @hostedZones["HostedZones"].push({})
                end
              end

              def add(hostedZones)
                 @hostedZones["HostedZones"].concat(hostedZones.get_hostedZones_array)
                 self
              end

              def get_json
                @hostedZones.to_json
              end

              def get_hostedZones_array
                @hostedZones["HostedZones"]
              end

            end
          end
        end
      end
    end
  end
end

