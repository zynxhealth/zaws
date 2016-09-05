module ZAWS
  class External
    class AWSCLI
      class Generators
        class API
          class EC2
            class CreateTags
              def initialize
                @resource
                @tags
                self
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

            end
          end
        end
      end
    end
  end
end

