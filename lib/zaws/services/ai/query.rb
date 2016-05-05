require 'yaml'

module ZAWS
  module Services
    module AI
      class Query

        def initialize(shellout, ai)
          @shellout=shellout
          @ai=ai
        end

        def kilo(n)
          count = 0
          while  n >= 1024 and count < 4
            n /= 1024.0
            count += 1
          end
          format("%.2f",n) + %w(B KB MB GB TB)[count]
        end

        def all(home,out,verbose=nil,value)
          results = {}
          @ai.nessusapi.home=home
          nessusapi_details = @ai.nessusapi.data_agents.view(1,verbose)
          results['nessus']= []
          nessusapi_details['agents'].each do |x|
             if x['ip'].include?(value) || x['name'].include?(value)
               x['last_scanned']= x['last_scanned']+ "   <--- #{DateTime.strptime(x['last_scanned'],'%s')}"
               results['nessus'] << x
             end
          end
          @ai.sumoapi.home=home
          sumoapi_details = @ai.sumoapi.data_collectors.view(verbose)
          results['sumo']= []
          sumoapi_details['collectors'].each do |x|
             if x['name'].include?(value)
               results['sumo'] << x
             end
          end
          @ai.newrelicapi.home=home
          newrelicapi_details = @ai.newrelicapi.data_servers.view(verbose)
          results['newrelic'] =[]
          newrelicapi_details['servers'].each do |x|
             if x['name'].include?(value)
               x['summary']['memory_used']="#{x['summary']['memory_used']} "+"<--- #{kilo(x['summary']['memory_used'])}"
               results['newrelic'] << x
             end
          end
          out.puts(results.to_yaml)
        end

      end
    end
  end
end