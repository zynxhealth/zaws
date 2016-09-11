module ZAWS
  class External
    class AWSCLI
      class Commands
        class Route53
          class ListHostedZones
            def initialize(shellout=nil, awscli=nil)
              @shellout=shellout
              @awscli=awscli
              @aws=nil
              self
            end

            def get_command
              command = "route53 list-hosted-zones"
              return command
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

