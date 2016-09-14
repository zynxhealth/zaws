module ZAWS
  class External
    class AWSCLI
      class Commands
        class EC2
          class Filter
            def initialize
              clear_settings
              self
            end

            def clear_settings()
              @domain=nil
              @instance_id=nil
              @group_name=nil
              @vpc_id=nil
              @cidr=nil
              @tags=nil
              @group_id=nil
              @ip_permission_group_id=nil
              @ip_permission_cidr=nil
              @ip_permission_protocol=nil
              @ip_permission_to_port=nil
            end

            def domain(domain)
              @domain=domain
              self
            end

            def instance_id(id)
              @instance_id=id
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

            def cidr(cidr)
              @cidr=cidr
              self
            end

            def tags(tags)
              @tags=tags.get_tags_array
              self
            end

            def group_id(id)
              @group_id=id
              self
            end

            def ip_permission_group_id(id)
              @ip_permission_group_id=id
              self
            end

            def ip_permission_cidr(cidr)
              @ip_permission_cidr=cidr
              self
            end

            def ip_permission_protocol(protocol)
              @ip_permission_protocol=protocol
              self
            end

            def ip_permission_to_port(port)
              @ip_permission_to_port=port
              self
            end

            def get_command
              command =""
              if !@vpc_id.nil? or !@group_name.nil? or
                  !@cidr.nil? or !@tags.nil? or
                  !@group_id.nil? or !@ip_permission_group_id.nil? or
                  !@ip_permission_cidr.nil? or !@ip_permission_protocol.nil? or
                  !@ip_permission_to_port.nil? or !@domain.nil? or
                  !@instance_id.nil?
                command = "--filter "
                command = "#{command}\"Name=domain,Values=#{@domain}\" " if @domain
                command = "#{command}\"Name=instance-id,Values=#{@instance_id}\" " if @instance_id
                command = "#{command}\"Name=vpc-id,Values=#{@vpc_id}\" " if @vpc_id
                command = "#{command}\"Name=group-name,Values=#{@group_name}\" " if @group_name
                command = "#{command}\"Name=cidr,Values=#{@cidr}\" " if @cidr
                command = "#{command}\"Name=group-id,Values=#{@group_id}\" " if @group_id
                command = "#{command}\"Name=ip-permission.group-id,Values=#{@ip_permission_group_id}\" " if @ip_permission_group_id
                command = "#{command}\"Name=ip-permission.cidr,Values=#{@ip_permission_cidr}\" " if @ip_permission_cidr
                command = "#{command}\"Name=ip-permission.protocol,Values=#{@ip_permission_protocol}\" " if @ip_permission_protocol
                command = "#{command}\"Name=ip-permission.to-port,Values=#{@ip_permission_to_port}\" " if @ip_permission_to_port
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
