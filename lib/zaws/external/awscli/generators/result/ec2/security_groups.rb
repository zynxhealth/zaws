module ZAWS
  class External
    class AWSCLI
      class Generators
        class Result
          class EC2
            class SecurityGroups
              def initialize
                @sgroups= {}
                @sgroups["SecurityGroups"]= []
                self
              end

              def group_name(security_group_number, name)
                resize_security_groups_array(security_group_number)
                @sgroups["SecurityGroups"][security_group_number]["GroupName"]=name
                self
              end

              def group_id(security_group_number, id)
                resize_security_groups_array(security_group_number)
                @sgroups["SecurityGroups"][security_group_number]["GroupId"]=id
                self
              end

              def vpc_id(security_group_number, id)
                resize_security_groups_array(security_group_number)
                @sgroups["SecurityGroups"][security_group_number]["VpcId"]=id
                self
              end

              def owner_id(security_group_number, id)
                resize_security_groups_array(security_group_number)
                @sgroups["SecurityGroups"][security_group_number]["OwnerId"]=id
                self
              end

              def description(security_group_number, description)
                resize_security_groups_array(security_group_number)
                @sgroups["SecurityGroups"][security_group_number]["Description"]=description
                self
              end

              def resize_security_groups_array(index)
                while index > @sgroups["SecurityGroups"].length-1
                  @sgroups["SecurityGroups"].push({})
                end
              end

              def get_json
                @sgroups.to_json
              end

              def get_security_groups_array
                @sgroups["SecurityGroups"]
              end

            end
          end
        end
      end
    end
  end
end

