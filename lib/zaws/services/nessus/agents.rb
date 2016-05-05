module ZAWS
  module Services
    module Nessus
      class Agents

        def initialize(shellout, nessus)
          @shellout=shellout
          @nessus=nessus
        end

        def view(home,scanner,out,verbose=nil)
          @nessus.nessusapi.home=home
          out.puts(@nessus.nessusapi.data_agents.view(scanner,verbose).to_yaml)
        end

      end
    end
  end
end