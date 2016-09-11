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

            def load(command, data, verbose)
              @security_group_raw_data = data
              verbose.puts(@security_group_raw_data) if verbose
              @security_group_hash=nil
              begin
                @security_group_hash =JSON.parse(data)
              rescue JSON::ParserError => e
              end
            end

            def view()
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
