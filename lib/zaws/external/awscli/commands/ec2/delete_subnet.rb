module ZAWS
  class External
    class AWSCLI
      class Commands
        class EC2
          class DeleteSubnet
            def initialize(shellout=nil, awscli=nil)
              @shellout=shellout
              @awscli=awscli
              clear_settings
              self
            end

            def clear_settings()
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

            def execute(verbose)
              comline=@aws.get_command
              @shellout.cli(comline, verbose)
            end

            def aws
              @aws ||= ZAWS::External::AWSCLI::Commands::AWS.new(self)
              @aws
            end

          end
        end
      end
    end
  end
end

