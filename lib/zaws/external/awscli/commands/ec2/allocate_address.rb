module ZAWS
  class External
    class AWSCLI
      class Commands
        class EC2
          class AllocateAddress
            def initialize(shellout=nil, awscli=nil)
              @shellout=shellout
              @awscli=awscli
              clear_settings
              self
            end

            def aws
              @aws ||= ZAWS::External::AWSCLI::Commands::AWS.new(self)
              @aws
            end

            def clear_settings
              @domain=nil
              @aws=nil
              self
            end

            def domain(domain)
              @domain=domain
              self
            end

            def get_command
              command = "ec2 allocate-addres"
              command = "#{command} --domain #{@domain}" if @domain
              return command
            end

          end
        end
      end
    end
  end
end

