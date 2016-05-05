require 'thor'

module ZAWS
  module Command
    class Newrelic < Thor
      class_option :verbose, :type => :boolean, :desc => "Verbose outout", :aliases => :d, :default => false

      attr_accessor :newrelic
      attr_accessor :out
      attr_accessor :print_exit_code

      def initialize(*args)
        super
        shellout=ZAWS::Helper::Shell.new
        newrelicapi = ZAWS::Newrelicapi.new(shellout)
        @newrelic = ZAWS::Controllers::Newrelic.new(shellout, newrelicapi)
        @out = $stdout
        @print_exit_code = false
      end

      desc "view_servers", "View Servers."
      option :home, :type => :string, :default => ENV['HOME'], :desc => 'Home directory location for credentials file'
      def view_servers
        @newrelic.servers.view(options[:home], @out, (options[:verbose] ? @out : nil))
      end

    end
  end
end

