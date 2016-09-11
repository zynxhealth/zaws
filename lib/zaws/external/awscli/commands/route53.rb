module ZAWS
  class AWSCLI
    class Commands
      class EC2
        def initialize(shellout, aws)
          @shellout=shellout
          @aws=aws
        end

        def listHostedZones
          @_listHostedZones ||= (ZAWS::External::AWSCLI::Commands::Route53::ListdHostedZones.new(@shellout, @aws))
          return @_listHostedZones
        end

      end
    end
  end
end

