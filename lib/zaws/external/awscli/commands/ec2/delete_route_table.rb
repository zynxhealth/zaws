module ZAWS
  class External
    class AWSCLI
      class Commands
        class EC2
          class DeleteRouteTable
            def initialize(shellout=nil, awscli=nil)
              @shellout=shellout
              @awscli=awscli
              clear_settings
              self
            end

            def clear_settings()
              @route_table_id=nil
              self
            end

            def route_table_id(id)
              @route_table_id=id
              self
            end

            def get_command
              command = "ec2 delete-route-table"
              command = "#{command} --route-table-id #{@route_table_id}" if @route_table_id
              return command
            end

            def execute(verbose)
              comline=@aws.get_command
              @shellout.cli(comline, verbose)
            end

            def aws
              @aws ||= ZAWS::External::AWSCLI::Commands::AWS.new(self)
              @aws
            end

          end
        end
      end
    end
  end
end

