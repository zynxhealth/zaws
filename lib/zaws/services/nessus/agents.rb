module ZAWS
  module Services
    module Nessus
      class Agents

        def initialize(shellout, nessus)
          @shellout=shellout
          @nessus=nessus
        end

        def view(params)
          @nessus.nessusapi.home=params['home']
          @nessus.nessusapi.data_agents.view(params['scanner'],nil).to_yaml
        end

      end
    end
  end
end