module ZAWS
  class External
    class AWSCLI
      class Generators
        class API
          class EC2
            class Filter
              def initialize
                @group_name=nil
                @vpc_id=nil
                @tags=nil
                self
              end

              def group_name(group_name)
                @group_name=group_name
                self
              end

              def vpc_id(vpc_id)
                @vpc_id=vpc_id
                self
              end

              def tags(tags)
                @tags=tags.get_tags_array
                self
              end

              def get_command
                command =""

                if !@vpc_id.nil? or !@group_name.nil?
                  command = "--filter "
                  command = "#{command}\"Name=vpc-id,Values=#{@vpc_id}\" " if @vpc_id
                  command = "#{command}\"Name=group-name,Values=#{@group_name}\" " if @group_name
                  if @tags
                  @tags.each do |x|
                    command = "#{command}\"Name=tag:#{x['Key']},Values=#{x['Value']}\" " if @tags
                  end
                 end
                end

                return command
              end

            end
          end
        end
      end
    end
  end
end

