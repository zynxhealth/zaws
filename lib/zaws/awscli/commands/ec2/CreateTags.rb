module ZAWS
  class AWSCLI
    class Commands
      class EC2
        class CreateTags

          def initialize(shellout, awscli)
            @shellout=shellout
            @awscli=awscli
          end

          def execute(instanceid, region, tag_key, tag_value, textout=nil, verbose=nil)
            comline="aws --output json --region #{region} ec2 create-tags --resources #{instanceid} --tags Key=#{tag_key},Value=#{tag_value}"
            @shellout.cli(comline, verbose)
          end

        end
      end
    end
  end
end
