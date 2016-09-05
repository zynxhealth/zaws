module ZAWS
  class AWSCLI
    class Data
     class IAM 
       class PolicyDocument

          def initialize(shellout,iam)
                @shellout=shellout
                @iam=iam
		     	@subnet_hash=nil
          end

		  def validJSON
			return (@subnet_hash.nil?)
		  end

		  def load(command,data,verbose)
			@policy_doc_raw_data = data 
			verbose.puts(@policy_doc_raw_data) if verbose 
			@policy_doc_hash=nil
			begin
			  @policy_doc_hash =JSON.parse(data)
			rescue JSON::ParserError => e
			end
		  end

		  def view()
			return @policy_doc_raw_data 
		  end

		  def resource_instance_ids()
			instance_ids=nil
	        if @policy_doc_hash and @policy_doc_hash["Statement"] 
			  statements = @policy_doc_hash["Statement"]
			  statements.each do |item|
				if item["Resource"]
				  item["Resource"].each do |res|
					if res =~ /:instance/
					   instance_ids += ("\n" + res[/([^\/]+)$/]) if ! instance_ids.nil?
                       instance_ids = res[/([^\/]+)$/] if instance_ids.nil?
					end
				  end
			    end
			  end
		    end
			instance_ids
		  end
        end
	  end
    end
  end
end
