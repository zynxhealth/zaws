
module ZAWS
  class AWSCLI

	def initialize(shellout)
	  @shellout=shellout
	end

	def version 
	  info = @shellout.cli("aws --version",nil)
	  #aws-cli/1.2.13 Python/2.7.5 Linux/3.10.0-123.el7.x86_64
	  version_match = /(?<version>aws-cli\/[1-9\.]*)/.match(info)
	  @version ||= version_match[:version]
  	  return @version
	end

  end
end

