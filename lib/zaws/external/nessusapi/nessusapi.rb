module ZAWS
  class Nessusapi

    attr_accessor :home

    def initialize(shellout)
      @shellout=shellout
    end

    def filestore
      @filestore ||= ZAWS::Repository::Filestore.new()
      @filestore.location="#{@home}/.nessusapi"
      unless File.directory?(@filestore.location)
			  FileUtils.mkdir_p(@filestore.location)
		  end
      @filestore.timeout = 600
      return @filestore
    end

    def remove_creds
      if File.directory?("#{@home}/.nessusapi")
        FileUtils.rmtree("#{@home}/.nessusapi")
      end
      if File.exist?("#{@home}/.nessus.yml")
        File.delete("#{@home}/.nessus.yml")
      end
    end

    def resource_scanners
      @_resource_scanners ||= (ZAWS::Nessusapi::Resources::Scanners.new(@shellout, self))
      return @_resource_scanners
    end

    def resource_agents
      @_resource_agents ||= (ZAWS::Nessusapi::Resources::Agents.new(@shellout, self))
      return @_resource_agents
    end

    def client
      fail("Home is null! Make sure its set before getting the client.") if @home== nil
      creds = ZAWS::Helper::NessusCreds::Creds::YamlFile.new(@home)
      @_client ||=  (ZAWS::Helper::NessusClient.new(creds))
    end

    def data_scanners
      @_data_scanners ||= (ZAWS::Nessusapi::Data::Scanners.new(@shellout, self))
      return @_data_scanners
    end

    def data_agents
      @_data_agents ||= (ZAWS::Nessusapi::Data::Agents.new(@shellout, self))
      return @_data_agents
    end

  end
end

