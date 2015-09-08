module ZAWS
  class AWSCLI
    class Data
     class IAM 
       class Policy

          def initialize(shellout,iam)
                @shellout=shellout
                @iam=iam
		     	@policy_hash=nil
          end

		  def validJSON
			return (@policy_hash.nil?)
		  end

		  def load(command,data,verbose)
			@policy_raw_data = data 
			verbose.puts(@policy_raw_data) if verbose 
			@policy_hash=nil
			begin
			  @policy_hash =JSON.parse(data)
			rescue JSON::ParserError => e
			end
		  end

		  def view()
			return @policy_raw_data 
		  end

		  def defaultVersion()
	        if @policy_hash and @policy_hash["Policy"] and @policy_hash["Policy"]["DefaultVersionId"]
			  return @policy_hash["Policy"]["DefaultVersionId"]
		    end
			return nil
		  end

        end
	  end
    end
  end
end
