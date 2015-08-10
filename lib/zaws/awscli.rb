
module ZAWS
  class AWSCLI

	def initialize(shellout)
	  @shellout=shellout
	end

	def version 
	  if ! @version
		info = @shellout.cli("aws --version",nil)
		#aws-cli/1.2.13 Python/2.7.5 Linux/3.10.0-123.el7.x86_64
		version_match = /(?<version>aws-cli\/[1-9\.]*)/.match(info)
		@version ||= version_match[:version]
	  end
  	  return @version
	end

	def command_ec2
	  @_command_ec2 ||= (ZAWS::AWSCLI::Commands::EC2.new(@shellout,self))
	  return @_command_ec2
    end

	def data_ec2
	  @_data_ec2 ||= (ZAWS::AWSCLI::Data::EC2.new(@shellout,self))
	  return @_data_ec2
	end

  end
end

