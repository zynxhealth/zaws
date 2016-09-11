module ZAWS
  class External
    class AWSCLI
      class Commands
        class AWS
          def initialize(subcommand=nil)
            @subcommand=subcommand
            @output=nil
            @region=nil
            self
          end

          def output(output)
            @output=output
            self
          end

          def region(region)
            @region=region
            self
          end

          def subcommand(subcommand)
            @subcommand=subcommand
            self
          end

          def get_command
            command = "aws "
            command = "#{command}--output #{@output} " if @output
            command = "#{command}--region #{@region} " if @region
            command = "#{command}#{@subcommand.get_command}" if @subcommand
            return command.strip
          end
        end
      end
    end
  end
end

