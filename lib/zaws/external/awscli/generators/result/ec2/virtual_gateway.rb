module ZAWS
  class External
    class AWSCLI
      class Generators
        class Result
          class EC2
            class VirtualGateway
              def initialize
                @addresses= {}
                self
              end

              def gateway_id(id)
                @addresses["GatewayId"]=id
                self
              end

              def get_json
                @addresses.to_json
              end

              def get_hash
                @addresses
              end
            end
          end
        end
      end
    end
  end
end

