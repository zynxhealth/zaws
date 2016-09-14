module ZAWS
  class External
    class AWSCLI
      class Generators
        class Result
          class EC2
            class AssociationId
              def initialize
                @addresses= {}
                self
              end

              def association_id(id)
                @addresses["AssociationId"]=id
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

