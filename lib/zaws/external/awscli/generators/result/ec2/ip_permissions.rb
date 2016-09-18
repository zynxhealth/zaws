module ZAWS
  class External
    class AWSCLI
      class Generators
        class Result
          class EC2
            class IpPermissions
              def initialize
                @ip_perms= {}
                @ip_perms["IpPermissions"]= []
                self
              end

              def to_port(security_group_number, port)
                resize_ip_permissions_array(security_group_number)
                @ip_perms["IpPermissions"][security_group_number]["ToPort"]=port
                self
              end

              def ip_protocol(security_group_number, proto)
                resize_ip_permissions_array(security_group_number)
                @ip_perms["IpPermissions"][security_group_number]["IpProtocol"]=proto
                self
              end

              def from_port(security_group_number, port)
                resize_ip_permissions_array(security_group_number)
                @ip_perms["IpPermissions"][security_group_number]["FromPort"]=port
                self
              end

              def resize_ip_permissions_array(index)
                while index > @ip_perms["IpPermissions"].length-1
                  @ip_perms["IpPermissions"].push({})
                end
              end

              def ip_ranges(security_group_number, cidr)
                resize_ip_permissions_array(security_group_number)
                @ip_perms["IpPermissions"][security_group_number]["IpRanges"] ||= []
                @ip_perms["IpPermissions"][security_group_number]["IpRanges"] << {'CidrIp' => cidr }
                self
              end

              def user_id_group_pairs(security_group_number, user_id, group_id)
                resize_ip_permissions_array(security_group_number)
                @ip_perms["IpPermissions"][security_group_number]["UserIdGroupPairs"] ||= []
                @ip_perms["IpPermissions"][security_group_number]["UserIdGroupPairs"] << {
                    'UserId' => user_id,
                    'GroupId' => group_id}
                self
              end

              def get_json
                @ip_perms.to_json
              end

              def get_ip_permissions_array
                @ip_perms["IpPermissions"]
              end

            end
          end
        end
      end
    end
  end
end


