module ZAWS
  class AWSCLI
    class Data
     class EC2
       class Instance

          def initialize(shellout,ec2)
                @shellout=shellout
                @ec2=ec2
		     	@instance_hash=nil
          end

		  def validJSON
			return (@instance_hash.nil?)
		  end

		  def load(command,data,verbose)
			@instance_raw_data = data 
			verbose.puts(@instance_raw_data) if verbose 
			@instance_hash=nil
			begin
			  @instance_hash =JSON.parse(data)
			  hash_ids_to_name_tag()
			rescue JSON::ParserError => e
			end
		  end

		  def view()
			return @instance_raw_data 
		  end

		  def name_tag_from_instance(single_instance_hash)
            instance_name = nil 
		    if single_instance_hash["Tags"]
               single_instance_hash["Tags"].each do |tag|
			      if tag["Key"] == "Name"
					 instance_name = tag["Value"] 
				  end
			   end
			end
			instance_name
		  end

		  def hash_ids_to_name_tag()
			@ids_to_names = {}
			if @instance_hash and @instance_hash["Reservations"]
			   @instance_hash["Reservations"].each do |res|
                if res["Instances"]
				   res["Instances"].each do |ins|
					 if ins["InstanceId"]
                       name_of_instance = name_tag_from_instance(ins) 
					   @ids_to_names[ins["InstanceId"]] = name_tag_from_instance(ins) 
					 end
				  end
				end
			  end
			end
		  end

		  def names_by_ids(instanceids)
            names = nil
			instanceids.split("\n").each do |item|
			  if @ids_to_names[item]
				names += "\n" + @ids_to_names[item] if ! names.nil?
                names = @ids_to_names[item] if names.nil?
			  end
			end
			names
		  end
       end
    end
    end
  end
end
