require 'fileutils'

module ZAWS
  class AWSCLI
  attr_accessor :home

	def initialize(shellout,keep_filestore_empty=false)
	  @shellout=shellout
		@keep_filestore_empty=keep_filestore_empty
	end

  def filestore
    @filestore ||= ZAWS::Repository::Filestore.new(@keep_filestore_empty)
		@filestore.timeout = 1800
		return @filestore if @keep_filestore_empty
		@home ||= ENV['HOME']
    @filestore.location="#{@home}/.awsdata"
		unless File.directory?(@filestore.location)
			FileUtils.mkdir_p(@filestore.location)
		end
    return @filestore
  end

  def remove_creds
		if File.directory?("#{@home}/.awsdata")
			FileUtils.rmtree("#{@home}/.awsdata")
		end
	  if File.exist?("#{@home}/.aws/credentials")
			File.delete("#{@home}/.aws/credentials")
		end
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

	def command_iam 
	  @_command_iam ||= (ZAWS::AWSCLI::Commands::IAM.new(@shellout,self))
	  return @_command_iam
    end

	def data_ec2
	  @_data_ec2 ||= (ZAWS::AWSCLI::Data::EC2.new(@shellout,self))
	  return @_data_ec2
	end

	def data_iam
	  @_data_iam ||= (ZAWS::AWSCLI::Data::IAM.new(@shellout,self))
	  return @_data_iam
	end

  end
end

