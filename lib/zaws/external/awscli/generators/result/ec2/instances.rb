module ZAWS
  class External
    class AWSCLI
      class Generators
        class Result
          class EC2
            class Instances
              def initialize
                @res= {}
                @res["Reservations"]= []
                @res["Reservations"] << { "Instances" => [] }
                self
              end

              def instance_id(instance_number, id)
                resize_instances_array(instance_number)
                @res["Reservations"][0]["Instances"][instance_number]["InstanceId"]=id
                self
              end

              def security_groups(instance_number,groups)
                @res["Reservations"][0]["Instances"][instance_number]["SecurityGroups"]=groups.get_security_groups_array
                self
              end

              def network_interfaces(instance_number,interfaces)
                 @res["Reservations"][0]["Instances"][instance_number]["NetworkInterfaces"]=interfaces.get_network_interfaces_array
                 self
              end

              def tags(instance_number,tags)
                 @res["Reservations"][0]["Instances"][instance_number]["Tags"]=tags.get_tags_array
                 self
              end

              def resize_instances_array(index)
                while index > @res["Reservations"][0]["Instances"].length-1
                 @res["Reservations"][0]["Instances"].push({})
                end
              end

              def get_json
                @res.to_json
              end

              def get_instances_array
                @res["Reservations"][0]["Instances"]
              end

            end
          end
        end
      end
    end
  end
end

