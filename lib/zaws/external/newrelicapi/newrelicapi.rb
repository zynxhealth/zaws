module ZAWS
  class Newrelicapi

    attr_accessor :home

    def initialize(shellout)
      @shellout=shellout
    end

    def filestore
      @filestore ||= ZAWS::Repository::Filestore.new()
      @filestore.location="#{@home}/.newrelicapi"
      unless File.directory?(@filestore.location)
        FileUtils.mkdir_p(@filestore.location)
      end
      @filestore.timeout = 600
      return @filestore
    end

    def remove_creds
      if File.directory?("#{@home}/.newrelicapi")
        FileUtils.rmtree("#{@home}/.newrelicapi")
      end
      if File.exist?("#{@home}/.newrelic.yml")
        File.delete("#{@home}/.newrelic.yml")
      end
    end

    def resource_servers
      @_resource_servers ||= (ZAWS::Newrelicapi::Resources::Servers.new(@shellout, self))
      return @_resource_servers
    end

    def client
      fail("Home is null! Make sure its set before getting the client.") if @home== nil
      creds = ZAWS::Newrelicapi::NewrelicCreds::Creds::YamlFile.new(@home)
      @_client ||= (ZAWS::Newrelicapi::NewrelicClient.new(creds))
    end

    def data_servers
      @_data_servers ||= (ZAWS::Newrelicapi::Data::Servers.new(@shellout, self))
      return @_data_servers
    end

  end
end
