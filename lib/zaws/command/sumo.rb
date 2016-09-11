require 'thor'

module ZAWS
  module Command
    class Sumo < Thor
      class_option :verbose, :type => :boolean, :desc => "Verbose outout", :aliases => :d, :default => false

      attr_accessor :sumo
      attr_accessor :out
      attr_accessor :print_exit_code

      def initialize(*args)
        super
        shellout=ZAWS::Helper::Shell.new
        sumoapi = ZAWS::Sumoapi.new(shellout)
        @sumo = ZAWS::Controllers::Sumo.new(shellout, sumoapi)
        @out = $stdout
        @print_exit_code = false
      end

      desc "view_collectors", "View Collectors."
      option :home, :type => :string, :default => ENV['HOME'], :desc => 'Home directory location for credentials file'
      def view_collectors
        @sumo.view(options[:home], @out, (options[:verbose] ? @out : nil))
      end

    end
  end
end

