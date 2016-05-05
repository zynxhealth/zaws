require 'thor'

module ZAWS
  module Command
    class Nessus < Thor
      class_option :verbose, :type => :boolean, :desc => "Verbose outout", :aliases => :d, :default => false

      attr_accessor :nessus
      attr_accessor :out
      attr_accessor :print_exit_code

      def initialize(*args)
        super
        shellout=ZAWS::Helper::Shell.new
        nessusapi = ZAWS::Nessusapi.new(shellout)
        @nessus = ZAWS::Controllers::Nessus.new(shellout, nessusapi)
        @out = $stdout
        @print_exit_code = false
      end

      desc "view_scanners", "View scanners."
      option :viewtype, :type => :string, :desc => "View type, json or table", :banner => "<viewtype>", :aliases => :w, :default => "table"
      option :home, :type => :string, :default => ENV['HOME'], :desc => 'Home directory location for credentials file'
      def view_scanners
        @nessus.scanners.view(options[:home], @out, (options[:verbose] ? @out : nil))
      end

      desc "view_agents", "View scanners."
      option :viewtype, :type => :string, :desc => "View type, json or table", :banner => "<viewtype>", :aliases => :w, :default => "table"
      option :home, :type => :string, :default => ENV['HOME'], :desc => 'Home directory location for credentials file'
      option :scanner, :type => :string, :default => '1', :desc => 'scanner id'
      def view_agents
        @nessus.agents.view(options[:home],options[:scanner], @out, (options[:verbose] ? @out : nil))
      end
    end
  end
end


