module ZAWS
  class External
    class AWSCLI
      class Generators
        class API
          class EC2
            class CreateSubnet
              def initialize
                @vpc_id=nil
                @cidr=nil
                @az=nil
                self
              end

              def vpc_id(vpc_id)
                @vpc_id=vpc_id
                self
              end

              def cidr(cidr)
                @cidr=cidr
                self
              end

              def availability_zone(az)
                @az=az
                self
              end

              def get_command
                command = "ec2 create-subnet"
                command = "#{command} --vpc-id #{@vpc_id}" if @vpc_id
                command = "#{command} --cidr-block #{@cidr}" if @cidr
                command = "#{command} --availability-zone #{@az}" if @az
                return command
              end

            end
          end
        end
      end
    end
  end
end

