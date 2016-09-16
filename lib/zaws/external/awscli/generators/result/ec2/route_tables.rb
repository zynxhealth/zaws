module ZAWS
  class External
    class AWSCLI
      class Generators
        class Result
          class EC2
            class RouteTables
              def initialize
                @route_tables= {}
                @route_tables["RouteTables"]= []
                @route_tables["Associations"]= []
                self
              end

              def vpc_id(route_table_number, vpc_id)
                resize_route_tables_array(route_table_number)
                @route_tables["RouteTables"][route_table_number]["VpcId"]=vpc_id
                self
              end

              def route_table_id(route_table_number, id)
                resize_route_tables_array(route_table_number)
                @route_tables["RouteTables"][route_table_number]["RouteTableId"]=id
                self
              end

              def resize_route_tables_array(index)
                while index > @route_tables["RouteTables"].length-1
                  @route_tables["RouteTables"].push({})
                end
                @route_tables["RouteTables"][index]["Associations"] ||= []
              end

              def add(route_tables)
                @route_tables["RouteTables"].concat(route_tables.get_route_tables_array)
                self
              end

              def associate_subnets(route_table_number,subnets)
                resize_route_tables_array(route_table_number)

                @route_tables["RouteTables"][route_table_number]["Associations"].concat(subnets.get_subnets_array)
                self
              end

              def get_json
                @route_tables.to_json
              end

              def get_json_single_route_table(index)
                single={"RouteTable" => @route_tables["RouteTables"][index]}
                single.to_json
              end

              def get_route_tables_array
                @route_tables["RouteTables"]
              end


            end
          end
        end
      end
    end
  end
end

