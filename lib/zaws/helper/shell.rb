require 'mixlib/shellout'

module ZAWS
  module Helper
	class Shell 

	  def cli(command,output=nil)
		output.puts ZAWS::Helper::Output.colorize(command,AWS_consts::COLOR_BLUE) if output
        list = Mixlib::ShellOut.new(command)
		list.run_command
		list.error!
		return list.stdout
	  end

	  def if_then(condition,command,output=nil)
		if not condition
		  output.puts ZAWS::Helper::Output.colorize(command,AWS_consts::COLOR_BLUE) if output
		  return nil 	
		end
		return cli(command,output)
	  end

	end
  end
end
