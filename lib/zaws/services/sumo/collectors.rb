module ZAWS
  module Services
    module Sumo
      class Collectors

        def initialize(shellout, sumo)
          @shellout=shellout
          @sumo=sumo
        end

        def view(home,out,verbose=nil)
          @sumo.sumoapi.home=home
          out.puts(@sumo.sumoapi.data_collectors.view(verbose).to_yaml)
        end

      end
    end
  end
end