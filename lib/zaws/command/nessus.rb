require 'thor'

module ZAWS
  module Command
    class Nessus < Thor
      class_option :verbose, :type => :boolean, :desc => "Verbose outout", :aliases => :d, :default => false
      class_option :home, :type => :string, :default => ENV['HOME'], :desc => 'Home directory location for credentials file'
      class_option :viewtype, :type => :string, :desc => "View type, json or table", :banner => "<viewtype>", :aliases => :w, :default => "table"

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
        @params= {
           'home' =>  options[:home]
        }
      end

      desc "view_scanners", "View scanners."
      def view_scanners
        @out.puts(@nessus.scanners.view(@params));
      end

      desc "view_agents", "View agents."
      option :scanner, :type => :string, :default => '1', :desc => 'scanner id'
      def view_agents
        @params['scanner']=options[:scanner]
        @out.puts(@nessus.agents.view(params));
      end
    end
  end
end


