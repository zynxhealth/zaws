module ZAWS
  class External
    class AWSCLI
      class Generators
        class Result
          class ELB
            class Listeners
              def initialize
                @listeners= {}
                @listeners["ListenerDescriptions"]= []
                self
              end

              def instance_port(listener_number, port)
                resize_listeners_array(listener_number)
                @listeners["ListenerDescriptions"][listener_number]["Listener"]["InstancePort"]=port
                self
              end

              def load_balancer_port(listener_number, port)
                resize_listeners_array(listener_number)
                @listeners["ListenerDescriptions"][listener_number]["Listener"]["LoadBalancerPort"]=port
                self
              end

              def protocol(listener_number, proto)
                resize_listeners_array(listener_number)
                @listeners["ListenerDescriptions"][listener_number]["Listener"]["Protocol"]=proto
                self
              end

              def instance_protocol(listener_number, proto)
                resize_listeners_array(listener_number)
                @listeners["ListenerDescriptions"][listener_number]["Listener"]["InstanceProtocol"]=proto
                self
              end

              def resize_listeners_array(index)
                while index > @listeners["ListenerDescriptions"].length-1
                  @listeners["ListenerDescriptions"].push({})
                end
                @listeners["ListenerDescriptions"][index]["Listener"] ||= {}
                @listeners["ListenerDescriptions"][index]["PolicyNames"] ||= []
              end

              def add(listeners)
                @listeners["ListenerDescriptions"].concat(listeners.get_listeners_array)
                self
              end

              def get_json
                @listeners.to_json
              end

              def get_listeners_array
                @listeners["ListenerDescriptions"]
              end

            end
          end
        end
      end
    end
  end
end
