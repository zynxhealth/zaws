module ZAWS
  class External
    class AWSCLI
      class Generators
        class Result
          class EC2
            class Addresses
              def initialize
                @addresses= {}
                @addresses["Addresses"]= []
                self
              end

              def instance_id(addres_number, id)
                resize_addresses_array(addres_number)
                @addresses["Addresses"][addres_number]["InstanceId"]=id
                self
              end

              def public_ip(addres_number, ip)
                resize_addresses_array(addres_number)
                @addresses["Addresses"][addres_number]["PublicIp"]=ip
                self
              end

              def domain(addres_number, domain)
                resize_addresses_array(addres_number)
                @addresses["Addresses"][addres_number]["Domain"]=domain
                self
              end

              def association_id(addres_number, id)
                resize_addresses_array(addres_number)
                @addresses["Addresses"][addres_number]["AssociationId"]=id
                self
              end

              def allocation_id(addres_number, id)
                resize_addresses_array(addres_number)
                @addresses["Addresses"][addres_number]["AllocationId"]=id
                self
              end

              def resize_addresses_array(index)
                while index > @addresses["Addresses"].length-1
                  @addresses["Addresses"].push({})
                end
              end

              def add(addresses)
                @addresses["Addresses"].concat(addresses.get_addresses_array)
                self
              end

              def get_json
                @addresses.to_json
              end

              def get_addresses_array
                @addresses["Addresses"]
              end

            end
          end
        end
      end
    end
  end
end

