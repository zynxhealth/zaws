module ZAWS
  class Sumoapi

    attr_accessor :home

    def initialize(shellout)
      @shellout=shellout
    end

    def filestore
      @filestore ||= ZAWS::Repository::Filestore.new()
      @filestore.location="#{@home}/.sumoapi"
      unless File.directory?(@filestore.location)
			  FileUtils.mkdir_p(@filestore.location)
		  end
      @filestore.timeout = 600
      return @filestore
    end

    def remove_creds
      if File.directory?("#{@home}/.sumoapi")
        FileUtils.rmtree("#{@home}/.sumoapi")
      end
      if File.exist?("#{@home}/.sumo.yml")
        File.delete("#{@home}/.sumo.yml")
      end
    end

    def resource_collectors
      @_resource_collectors ||= (ZAWS::Sumoapi::Resources::Collectors.new(@shellout, self))
      return @_resource_collectors
    end

    def client
      fail("Home is null! Make sure its set before getting the client.") if @home== nil
      creds = ZAWS::Sumoapi::SumoCreds::Creds::YamlFile.new(@home)
      @_client ||=  (ZAWS::Sumoapi::SumoClient.new(creds))
    end

    def data_collectors
      @_data_collectors ||= (ZAWS::Sumoapi::Data::Collectors.new(@shellout, self))
      return @_data_collectors
    end

  end
end
