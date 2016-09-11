module ZAWS
  class External
    class AWSCLI
      class Commands
        class Route53
          class ListResourceRecordSets
            def initialize(shellout=nil, awscli=nil)
              @shellout=shellout
              @awscli=awscli
              clear_settings
              self
            end

            def clear_settings
              @aws=nil
              @hosted_zone_id=nil
            end

            def hosted_zone_id(id)
              @hosted_zone_id=id
              self
            end

            def get_command
              command = "route53 list-resource-record-sets"
              command = "#{command} --hosted-zone-id #{@hosted_zone_id}" if @hosted_zone_id
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

