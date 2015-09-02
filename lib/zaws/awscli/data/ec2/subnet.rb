module ZAWS
  class AWSCLI
    class Data
     class EC2
       class Subnet

          def initialize(shellout,ec2)
                @shellout=shellout
                @ec2=ec2
		     	@subnet_hash=nil
          end

		  def validJSON
			return (@subnet_hash.nil?)
		  end

		  def load(command,data,textout)
			@subnet_raw_data = data 
			textout.puts(@subnet_raw_data) if textout 
			@subnet_hash=nil
			begin
			  @subnet_hash =JSON.parse(data)
			rescue JSON::ParserError => e
			end
		  end

		  def view()
			return @subnet_raw_data 
		  end

          def available()
            if @subnet_hash and @subnet_hash["Subnet"]
              return (@subnet_hash["Subnet"]["State"] == "available")
            end
            if @subnet_hash and @subnet_hash["Subnets"] and @subnet_hash["Subnets"].count == 1
              return (@subnet_hash["Subnets"][0]["State"] == "available")
            end
            return false
          end

       end
    end
    end
  end
end
