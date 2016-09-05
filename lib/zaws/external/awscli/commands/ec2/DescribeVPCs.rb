module ZAWS
  class AWSCLI
    class Commands
      class EC2
        class DescribeVPCs

          def initialize(shellout, awscli)
            @shellout=shellout
            @awscli=awscli
          end

          def execute(region, view, filters, verbose=nil,profile=nil)
            profile_opt=profile.nil? ? '' :" --profile #{profile}"
            comline="aws --output #{view} --region #{region} ec2 describe-vpcs#{profile_opt}"
            comline = comline + " --filters" if filters.length > 0
            filters.each do |key, item|
              comline = comline + " \"Name=#{key},Values=#{item}\""
            end
            @awscli.data_ec2.vpc.load(comline, @shellout.cli(comline, verbose),verbose)
          end

        end
      end
    end
  end
end