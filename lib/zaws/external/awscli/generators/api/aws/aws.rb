module ZAWS
  class External
    class AWSCLI
      class Generators
        class API
          class AWS
            class AWS
              def initialize
                @subcommand=nil
                @output=nil
                @region=nil
                self
              end

              def with_output(output)
                @output=output
                self
              end

              def with_region(region)
                @region=region
                self
              end

              def with_subcommand(subcommand)
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
  end
end

