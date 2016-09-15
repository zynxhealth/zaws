module ZAWS
  class External
    class AWSCLI
      class Commands
        class EC2
          class UnassignPrivateIpAddresses
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
              @network_interface_id=nil
              @private_ip_addresses=nil
              @aws=nil
              self
            end

            def network_interface_id(id)
              @network_interface_id=id
              self
            end

            def private_ip_addresses(ip)
              @private_ip_addresses=ip
              self
            end

            def get_command
              command = "ec2 unassign-private-ip-addresses"
              command = "#{command} --network-interface-id \"#{@network_interface_id}\"" if @network_interface_id
              command = "#{command} --private-ip-addresses \"#{@private_ip_addresses}\"" if @private_ip_addresses
              return command
            end
          end
        end
      end
    end
  end
end


