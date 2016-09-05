module ZAWS
  module Services
    module Nessus
      class Scanners

        def initialize(shellout, nessus)
          @shellout=shellout
          @nessus=nessus
        end

        def view(params)
          @nessus.nessusapi.home=params['home']
          @nessus.nessusapi.data_scanners.view(nil).to_yaml
        end

      end
    end
  end
end