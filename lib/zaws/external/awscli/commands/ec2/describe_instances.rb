module ZAWS
  class External
    class AWSCLI
      class Commands
        class EC2
          class DescribeInstances

            def initialize(shellout=nil, awscli=nil)
              #super(shellout, awscli)
              @shellout=shellout
              @awscli=awscli
              clear_settings
            end

            def aws
              @aws ||= ZAWS::External::AWSCLI::Commands::AWS.new(self)
              @aws
            end

            def filter
              @filter ||= ZAWS::External::AWSCLI::Commands::EC2::Filter.new()
              @filter
            end

            def clear_settings
              @aws=nil
              @filter=nil
            end

            def get_command
              command = "ec2 describe-instances"
              command = "#{command} #{@filter.get_command}" if @filter
              return command
            end

            def execute(region, view, filters={}, textout=nil, verbose=nil, profile=nil)
              comline = "aws"
              comline = comline + " --output #{view}"
              comline = comline + " --region #{region} ec2 describe-instances"
              comline = comline + " --profile #{profile}" if profile
              comline = comline + " --filter" if filters.length > 0
              filters.each do |key, item|
                comline = comline + " \"Name=#{key},Values=#{item}\""
              end
              unless @awscli.data_ec2.instance.load_cached(comline, verbose)
                @awscli.data_ec2.instance.load(comline, @shellout.cli(comline, verbose), verbose)
              end
            end

          end
        end
      end
    end
  end
end

