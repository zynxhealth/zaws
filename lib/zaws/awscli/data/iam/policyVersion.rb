module ZAWS
  class AWSCLI
    class Data
     class IAM 
       class PolicyVersion

          def initialize(shellout,iam)
                @shellout=shellout
                @iam=iam
		     	@policy_ver_hash=nil
          end

		  def validJSON
			return (@policy_ver_hash.nil?)
		  end

		  def load(command,data,verbose)
			@policy_ver_raw_data = data 
			verbose.puts(@policy_ver_raw_data) if verbose 
			@policy_ver_hash=nil
			begin
			  @policy_ver_hash =JSON.parse(data)
			rescue JSON::ParserError => e
			end
		  end

		  def view()
			return @policy_ver_raw_data 
		  end

        end
	  end
    end
  end
end
