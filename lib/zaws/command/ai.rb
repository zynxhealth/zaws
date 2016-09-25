require 'thor'

module ZAWS
  module Command
    class Ai < Thor
      class_option :verbose, :type => :boolean, :desc => "Verbose outout", :aliases => :d, :default => false

      attr_accessor :ai
      attr_accessor :out
      attr_accessor :print_exit_code

      def initialize(*args)
        super
        shellout=ZAWS::Helper::Shell.new
        nessusapi = ZAWS::Nessusapi.new(shellout)
        sumoapi = ZAWS::Sumoapi.new(shellout)
        newrelicapi = ZAWS::Newrelicapi.new(shellout)
        awscli = ZAWS::AWSCLI.new(shellout)
        @ai = ZAWS::Controllers::AI.new(shellout, nessusapi,sumoapi,newrelicapi,awscli)
        @out = $stdout
        @print_exit_code = false
      end

      desc "query", "query"
      option :home, :type => :string, :default => ENV['HOME'], :desc => 'Home directory location for credentials file'
      def query(*value)
        @ai.awscli.home=options[:home]
        value = [value] if value.instance_of?(String)
        @out.puts(@ai.query.all(options[:home], options[:verbose],value))
      end

    end
  end
end