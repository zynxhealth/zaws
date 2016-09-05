module ZAWS
  class AWSCLI
  
    def main_regions 
      return ['us-east-1',
                    'us-west-2',   
                    'us-west-1',   
                    'ap-southeast-1']
    end 
   
    def extended_Regions 
      return ['us-east-1',
                        'eu-central-1',
                        'ap-southeast-1',
                        'ap-northeast-1',
                        'ap-southeast-2',
                        'ap-northeast-2',
                        'sa-east-1']
    end


  end
end