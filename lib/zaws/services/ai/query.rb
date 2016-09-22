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
          while n >= 1024 and count < 4
            n /= 1024.0
            count += 1
          end
          format("%.2f", n) + %w(B KB MB GB TB)[count]
        end

        def all(home, out, verbose=nil, value)
          results = {}
          value_array=[]
          value_array.concat(value)
          query_aws(value_array, verbose, results)
          query_nessus(home, results, value_array, verbose)
          #query_sumo(home, results, value_array, verbose)
          query_newrelic(home, results, value_array, verbose)
          results=ZAWS::Helper::ProcessHash.keep(results,value_array)
          out.puts(results.to_yaml)
        end

        def query_nessus(home, results, value_array, verbose)
          @ai.nessusapi.home=home
          nessusapi_details = @ai.nessusapi.data_agents.view(1, verbose)
          results['nessus']= []
          nessusapi_details['agents'].each do |x|
            value_array.each do |value|
              if x['ip'].include?(value) || x['name'].include?(value)
                if x['last_scanned']
                  x['last_scanned']= x['last_scanned'] + "   <--- #{DateTime.strptime(x['last_scanned'], '%s')}"
                end
                results['nessus'] << x
                break
              end
            end
          end
        end

        def query_sumo(home, results, value_array, verbose)
          @ai.sumoapi.home=home
          sumoapi_details = @ai.sumoapi.data_collectors.view(verbose)
          results['sumo']= []
          sumoapi_details['collectors'].each do |x|
            value_array.each do |value|
              if x['name'].include?(value)
                sumoapi_sources=@ai.sumoapi.data_sources.view(verbose, x['id'])
                x['sources']=sumoapi_sources
                results['sumo'] << x
                break
              end
            end
          end
        end

        def query_aws(value, verbose, results)
          profile_creds=ZAWS::AWSCLI::Credentials.new("#{@ai.awscli.home}/.aws/credentials")
          item = []
          profile_creds.profiles.each do |profile|
            @ai.awscli.main_regions.each do |region|
              filters= {}
              @ai.awscli.command_ec2.describeInstances.execute(region, 'json', filters, nil, verbose, profile)
              res = @ai.awscli.data_ec2.instance.view('hash')
              res['profile']=profile
              item << res
            end
          end
          results['awscli']= []
          item.each do |reservations|
            reservations['Reservations'].each do |reservation|
              reservation['Instances'].each do |instance|
                found=false
                found=true if instance['InstanceId'] and instance['InstanceId'].include?(value[0])
                found=true if instance['PrivateIpAddress'] and instance['PrivateIpAddress'].include?(value[0])
                if instance['Tags']
                  instance['Tags'].each do |tag|
                    if tag['Value'] and tag['Value'].include?(value[0])
                      found=true
                    end
                  end
                end
                if found
                  instance['profile']=reservations['profile']
                  results['awscli'] << instance
                  value << instance['InstanceId']
                  if instance['PrivateIpAddress']
                    value << instance['PrivateIpAddress'] unless instance['PrivateIpAddress'].include?(value[0])
                    value << instance['PrivateIpAddress'].gsub('.', '-') unless instance['PrivateIpAddress'].gsub('.', '-').include?(value[0])
                  end
                  if instance['Tags']
                    instance['Tags'].each do |tag|
                      if tag['Key'].equal?('Name')
                        value << tag['Value'] unless tag['Value'].include?(value[0])
                      end
                    end
                  end
                end
              end
            end
          end
        end

        def query_newrelic(home, results, value_array, verbose)
          @ai.newrelicapi.home=home
          newrelicapi_details = @ai.newrelicapi.data_servers.view(verbose)
          results['newrelic'] =[]
          newrelicapi_details['servers'].each do |x|
            value_array.each do |value|
              if x['name'].include?(value)
                if x['summary'] and x['summary']['memory_used']
                  x['summary']['memory_used']="#{x['summary']['memory_used']}"+"  <--- #{kilo(x['summary']['memory_used'])}"
                end
                results['newrelic'] << x
                break
              end
            end
          end
        end

      end
    end
  end
end