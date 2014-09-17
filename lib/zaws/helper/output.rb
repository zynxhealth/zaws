require 'json'

module AWS_consts
  # Color codes http://kpumuk.info/ruby-on-rails/colorizing-console-ruby-script-output/
  COLOR_RED=31
  COLOR_GREEN=32
  COLOR_YELLOW=33
  COLOR_DEFAULT=39
  COLOR_BLUE=34
  COLOR_CYAN=36
end

module ZAWS
  module Helper
    class Output

      def self.colorize(text, color_code)
        "\e[#{color_code}m#{text}\e[0m"
      end

      def self.opt_required(output, opt_arr)
        opt_arr.each { |opt| output.puts(" --#{opt} required!") }
      end

      def self.opt_exclusive(output, opt_arr)
        output.puts("  These options cannot be combined:")
        opt_arr.each { |opt| output.puts("    --#{opt}") }
      end

      def self.opt_minimum(output, min, opt_arr)
        output.puts("  At mininum, #{min} of the following is required:")
        opt_arr.each { |opt| output.puts("    --#{opt}") }
      end

      def self.binary_nagios_check(ok_condition, ok_msg, critical_msg, textout=nil)
        if ok_condition
          textout.puts ok_msg if textout
          return 0
        else
          textout.puts critical_msg if textout
          return 2
        end
      end

      def self.cloudtrail(json_data, format = "csv")
        parsed = JSON.parse(json_data)
        records = parsed["Records"]

        str_out = ""
        if format == "csv"
          records.each do |record|
            str_out << "#{record["userIdentity"]["userName"]}, "
            str_out << "#{record["eventTime"]}, "
            str_out << "#{record["eventSource"]}, "
            str_out << "#{record["eventName"]}"

            if record["errorCode"]
              str_out << ", "
              str_out << "#{record["errorCode"]}, "
              str_out << "#{record["errorMessage"]}"
            end

            str_out << "\n"
          end
        elsif format == "raw"
          str_out=json_data 
        end

        return str_out
      end

    end
  end
end
