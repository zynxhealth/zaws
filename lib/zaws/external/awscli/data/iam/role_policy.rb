module ZAWS
  class AWSCLI
    class Data
      class IAM
        class RolePolicy

          def initialize(shellout, iam)
            @shellout=shellout
            @iam=iam
            @subnet_hash=nil
          end

          def validJSON
            return (@subnet_hash.nil?)
          end

          def load(command, data, verbose)
            @subnet_raw_data = data
            verbose.puts(@subnet_raw_data) if verbose
            @subnet_hash=nil
            begin
              @subnet_hash =JSON.parse(data)
            rescue JSON::ParserError => e
            end
          end

          def view()
            return @subnet_raw_data
          end

          def resource_instance_ids()
            instance_ids=nil
            if @subnet_hash and @subnet_hash["PolicyDocument"] and @subnet_hash["PolicyDocument"]["Statement"]
              statements = @subnet_hash["PolicyDocument"]["Statement"]
              statements.each do |item|
                if item["Resource"]
                  item["Resource"].each do |res|
                    if res =~ /:instance/
                      instance_ids += ("\n" + res[/([^\/]+)$/]) if !instance_ids.nil?
                      instance_ids = res[/([^\/]+)$/] if instance_ids.nil?
                    end
                  end
                end
              end
            end
            instance_ids
          end
        end
      end
    end
  end
end
