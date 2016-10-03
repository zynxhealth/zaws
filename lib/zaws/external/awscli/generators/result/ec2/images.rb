module ZAWS
  class External
    class AWSCLI
      class Generators
        class Result
          class EC2
            class Images
              def initialize
                @res= {}
                @res["Images"]= []
                self
              end

              def root_device_name(image_number, name)
                resize_images_array(image_number)
                @res["Images"][image_number]["RootDeviceNmae"]=name
                self
              end

              def block_device_mappings(image_number,block)
                @res["Images"][image_number]["BlockDeviceMappings"]=block
                self
              end

              def resize_images_array(index)
                while index > @res["Images"].length-1
                 @res["Images"].push({})
                end
              end

              def get_json
                @res.to_json
              end

              def get_images_array
                @res["Images"]
              end

            end
          end
        end
      end
    end
  end
end

