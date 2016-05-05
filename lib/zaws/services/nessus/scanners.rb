module ZAWS
  module Services
    module Nessus
      class Scanners

        def initialize(shellout, nessus)
          @shellout=shellout
          @nessus=nessus
        end

        def view(home,out,verbose=nil)
          @nessus.nessusapi.home=home
          @nessus.nessusapi.data_scanners.view(verbose)
        end

      end
    end
  end
end