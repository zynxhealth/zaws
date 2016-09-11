module ZAWS
  class AWSCLI
    class Commands
      class ELB
        def initialize(shellout, aws)
          @shellout=shellout
          @aws=aws
        end

        def describeLoadBalancers
          @_describeLoadBalancers ||= (ZAWS::External::AWSCLI::Commands::ELB::DescribeLoadBalancers.new(@shellout, @aws))
          return @_describeLoadBalancers
        end

      end
    end
  end
end

