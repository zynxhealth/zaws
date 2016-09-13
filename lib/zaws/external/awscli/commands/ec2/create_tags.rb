module ZAWS
  class External
    class AWSCLI
      class Commands
        class EC2
          class CreateTags
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
              @resource=nil
              @tags=nil
              @aws=nil
            end

            def resource(resource)
              @resource=resource
              self
            end

            def tags(tags)
              @tags=tags.get_tags_array
              self
            end

            def get_command
              command = "ec2 create-tags"
              command = "#{command} --resources #{@resource}" if @resource
              command = "#{command} --tags \"Key=#{@tags[0]['Key']},Value=#{@tags[0]['Value']}\" " if @tags
              return command
            end

            def execute(instanceid, region, tag_key, tag_value, textout=nil, verbose=nil)
              comline="aws --output json --region #{region} ec2 create-tags --resources #{instanceid} --tags \"Key=#{tag_key},Value=#{tag_value}\""
              @shellout.cli(comline, verbose)
            end

          end
        end
      end
    end
  end
end

