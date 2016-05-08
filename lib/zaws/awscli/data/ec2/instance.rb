module ZAWS
  class AWSCLI
    class Data
      class EC2
        class Instance

          def initialize(shellout, ec2)
            @shellout=shellout
            @ec2=ec2
            @instance_hash=nil
          end

          def validJSON
            return (@instance_hash.nil?)
          end

          def load_cached(command,verbose)
            fileinstances = @ec2.filestore.retrieve("instance",command)
            if fileinstances.nil?
              return false
            else
              load(command,fileinstances,verbose,false)
              return true
            end
          end

          def load(command, data, verbose,cache=true)
            @instance_raw_data = data
            verbose.puts(@instance_raw_data) if verbose
            @instance_hash=nil
            begin
              @instance_hash =JSON.parse(data)
              create_lookup_hashes()
              @ec2.filestore.store("instance",@instance_raw_data,Time.now + @ec2.filestore.timeout,command) if cache
            rescue JSON::ParserError => e
            end
          end

          def view(view=nil)
            if view=="yaml"
               return @instance_hash.to_yaml
            elsif view=="hash"
               return @instance_hash
            else
               return @instance_raw_data
            end
          end

          def hash_identification(single_instance_hash)
            instance_name = nil
            instance_externalid = nil
            if single_instance_hash["Tags"]
              single_instance_hash["Tags"].each do |tag|
                instance_name = tag["Value"] if tag["Key"] == "Name"
                instance_externalid = tag["Value"] if tag["Key"] == "Name"
              end
            end
            @ids_to_names[single_instance_hash["InstanceId"]] = instance_name if single_instance_hash["InstanceId"] and instance_name
            @ids_to_externalid[single_instance_hash["InstanceId"]] = instance_externalid if single_instance_hash["InstanceId"] and instance_externalid
            @externalids_to_id[instance_externalid] = single_instance_hash["InstanceId"] if single_instance_hash["InstanceId"] and instance_externalid
            @names_to_id[instance_name] = single_instance_hash["InstanceId"] if single_instance_hash["InstanceId"] and instance_name
          end

          def create_lookup_hashes()
            @ids_to_names = {}
            @ids_to_externalid = {}
            @externalids_to_id = {}
            @names_to_id = {}
            @names_to_status = {}
            @externalid_to_status = {}
            @ids_interval={}
            if @instance_hash and @instance_hash["Reservations"]
              @instance_hash["Reservations"].each do |res|
                if res["Instances"]
                  res["Instances"].each do |ins|
                    hash_identification(ins)
                    hash_status(ins)
                    hash_interval(ins)
                  end
                end
              end
            end
          end

          def hash_interval(single_instance_hash)
            instance_interval =nil
            if single_instance_hash["Tags"]
              single_instance_hash["Tags"].each do |tag|
                instance_interval = tag["Value"] if tag["Key"] == "interval"
              end
            end
            @ids_interval[single_instance_hash["InstanceId"]]=instance_interval if single_instance_hash["InstanceId"] and instance_interval
          end

          def hash_status(single_instance_hash)
            instance_name = nil
            instance_externalid = nil
            instance_status = nil
            if single_instance_hash["Tags"]
              single_instance_hash["Tags"].each do |tag|
                instance_name = tag["Value"] if tag["Key"] == "Name"
                instance_externalid = tag["Value"] if tag["Key"] == "externalid"
              end
            end
            instance_status = single_instance_hash["State"]["Name"] if single_instance_hash["State"] and single_instance_hash["State"]["Name"]
            @names_to_status[instance_name]=instance_status if instance_status and instance_name
            @externalid_to_status[instance_externalid]=instance_status if instance_status and instance_externalid
          end

          def status(name, externalid)
            return @names_to_status[name] if @names_to_status[name]
            return @externalid_to_status[externalid] if @externalid_to_status[externalid]
            return "unknown"
          end

          def instanceid(name, externalid)
            return @names_to_id[name] if @names_to_id[name]
            return @externalids_to_id[externalid] if @externalids_to_id[externalid]
            return "unknown"
          end

          def externalid(instanceid)
            return @ids_to_externalid[instanceid] if @ids_to_externalid[instanceid]
            return "unknown"
          end

          def name(instanceid)
            return @ids_to_names[instanceid] if @ids_to_names[instanceid]
            return "unknown"
          end

          def has_interval?(instanceid)
            return @ids_interval[instanceid] ? true : false
          end

          def interval_start(instanceid)
            return @ids_interval[instanceid] ? @ids_interval[instanceid].split(":")[0] : "-1"
          end

          def interval_end(instanceid)
            return @ids_interval[instanceid] ? @ids_interval[instanceid].split(":")[1] : "-1"
          end

          def interval_email(instanceid)
            return @ids_interval[instanceid] ? @ids_interval[instanceid].split(":")[2] : "-1"
          end

          def names_by_ids(instanceids)
            names = nil
            instanceids.split("\n").each do |item|
              if @ids_to_names[item]
                names += "\n" + @ids_to_names[item] if !names.nil?
                names = @ids_to_names[item] if names.nil?
              end
            end
            return names
          end
        end
      end
    end
  end
end
