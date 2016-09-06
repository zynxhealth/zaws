module ZAWS
  class External
    class AWSCLI
      class Generators
        class API
          class EC2
            class DeleteSubnet
              def initialize
                @subnet_id=nil
                self
              end

              def subnet_id(id)
                @subnet_id=id
                self
              end

              def get_command
                command = "ec2 delete-subnet"
                command = "#{command} --subnet-id #{@subnet_id}" if @subnet_id
                return command
              end

            end
          end
        end
      end
    end
  end
end

