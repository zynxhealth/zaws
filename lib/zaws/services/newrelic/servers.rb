module ZAWS
  module Services
    module Newrelic
      class Servers

        def initialize(shellout, newrelic)
          @shellout=shellout
          @newrelic=newrelic
        end

        def view(home,out,verbose=nil)
          @newrelic.newrelicapi.home=home
          out.puts(@newrelic.newrelicapi.data_servers.view(verbose).to_yaml)
        end

      end
    end
  end
end
