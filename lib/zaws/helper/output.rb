
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

	  def self.opt_required(output,opt_arr)
		opt_arr.each { |opt| output.puts(" --#{opt} required!") }
	  end

      def self.opt_exclusive(output,opt_arr)
        output.puts("  These options cannot be combined:")
		opt_arr.each { |opt| output.puts("    --#{opt}") }
	  end

      def self.opt_minimum(output,min,opt_arr)
        output.puts("  At mininum, #{min} of the following is required:")
		opt_arr.each { |opt| output.puts("    --#{opt}") }
	  end

      def self.binary_nagios_check(ok_condition,ok_msg,critical_msg,textout=nil)
        if ok_condition
          textout.puts ok_msg if textout
		  return 0
		else
          textout.puts critical_msg if textout
		  return 2
		end
	  end

	end
  end
end
