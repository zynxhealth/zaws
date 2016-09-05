module ZAWS
  class External
    class AWSCLI
      class Generators
        class Result
          class EC2
            class Tags
              def initialize
                @tags= {}
                @tags["Tags"]= []
                self
              end

              def add(key, value)
                @tags["Tags"] << { "Value"=>value,"Key"=>key }
                self
              end

              def get_json
                @tags.to_json
              end

              def get_tags_array
                @tags["Tags"]
              end

            end
          end
        end
      end
    end
  end
end

