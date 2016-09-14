module ZAWS
  class External
    class AWSCLI
      class Data
        class EC2
          class SecurityGroup

            def initialize(shellout, ec2)
              @shellout=shellout
              @ec2=ec2
              @ssecurity_group_hash=nil
            end

            def validJSON
              return (@security_group_hash.nil?)
            end

            def load(data, verbose)
              @security_group_raw_data = data
              verbose.puts(@security_group_raw_data) if verbose
              @security_group_hash=nil
              begin
                @security_group_hash=JSON.parse(data)
              rescue JSON::ParserError => e
              end
            end

            def view(viewtype=nil,verbose=nil)
              details = @ec2.filestore.retrieve("securitygroups#{viewtype}", @ec2.command_ec2.describeSecurityGroups.aws.get_command)
              if details.nil?
                verbose.puts "Did not use cache." if verbose
                load(@ec2.command_ec2.describeSecurityGroups.execute(verbose), verbose)
                @ec2.filestore.store("securitygroups#{viewtype}", @security_group_raw_data, Time.now + @ec2.filestore.timeout, @ec2.command_ec2.describeSecurityGroups.aws.get_command)
              else
                verbose.puts "used cache." if verbose
                load(details, verbose)
              end
              return @security_group_raw_data
            end

            def exists
              val = (@security_group_hash["SecurityGroups"].count == 1)
              sgroupid = val ? @security_group_hash["SecurityGroups"][0]["GroupId"] : nil
              return val, sgroupid
            end
          end
        end
      end
    end
  end
end
