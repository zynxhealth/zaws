module ZAWS
  class AWSCLI
    class Data
      class EC2

        def initialize(shellout, aws)
          @shellout=shellout
          @aws=aws
        end

        def filestore
          @aws.filestore
        end

        def subnet
          @_Subnet ||= (ZAWS::AWSCLI::Data::EC2::Subnet.new(@shellout, self))
          return @_Subnet
        end

        def instance
          @_Instance ||= (ZAWS::AWSCLI::Data::EC2::Instance.new(@shellout, self.filestore))
          return @_Instance
        end

        def vpc
          @_vpc ||= (ZAWS::AWSCLI::Data::EC2::VPC.new(@shellout, self))
          return @_vpc
        end

      end
    end
  end
end
