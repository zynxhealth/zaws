module ZAWS
  class External
    class AWSCLI
      class Generators
        class Result
          class EC2
            class AllocationId
              def initialize
                @addresses= {}
                self
              end

              def public_ip(ip)
                @addresses["PublicIp"]=ip
                self
              end

              def domain(domain)
                @addresses["Domain"]=domain
                self
              end

              def allocation_id(id)
                @addresses["AllocationId"]=id
                self
              end

              def get_json
                @addresses.to_json
              end

            end
          end
        end
      end
    end
  end
end

