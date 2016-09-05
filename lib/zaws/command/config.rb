require 'thor'

module ZAWS
  module Command
    class Config < Thor
      class_option :verbose, :type => :boolean, :desc => "Verbose outout", :aliases => :d, :default => false

      attr_accessor :config
      attr_accessor :out
      attr_accessor :print_exit_code

      def initialize(*args)
        super
        shellout=ZAWS::Helper::Shell.new
        nessusapi = ZAWS::Nessusapi.new(shellout)
        sumoapi = ZAWS::Sumoapi.new(shellout)
        newrelicapi = ZAWS::Newrelicapi.new(shellout)
        awscli = ZAWS::AWSCLI.new(shellout)
        @config = ZAWS::Controllers::Config.new(shellout, nessusapi,sumoapi,newrelicapi,awscli)
        @out = $stdout
        @print_exit_code = false
      end

      desc "remove_creds", "remove_creds"
      option :home, :type => :string, :default => ENV['HOME'], :desc => 'Home directory location for credentials file'
      def remove_creds
        @config.awscli.home=options[:home]
        @config.awscli.remove_creds()

        @config.nessusapi.home=options[:home]
        @config.nessusapi.remove_creds()

        @config.sumoapi.home=options[:home]
        @config.sumoapi.remove_creds()

        @config.newrelicapi.home=options[:home]
        @config.newrelicapi.remove_creds()
      end

    end
  end
end
