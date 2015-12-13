require 'spec_helper'

describe ZAWS::AWSCLI::Data::EC2::Instance do
  # var_ - Version A. awscli 1.2.13 Return
  # vap_ - Version A. awscli 1.2.13 Parameter 
  # vac_ - Version A. awscli 1.2.13 Command 

  let(:vap_describe_instance) { <<-eos
		{
			"Reservations": [
				{
					"OwnerId": "123456789abc",
					"ReservationId": "r-88ef5d66",
					"Groups": [],
					"Instances": [
						{
							"State": {
								"Code": 80,
								"Name": "stopped"
							},
							"InstanceId": "i-abcdefg1",
							"Tags": [
								{
									"Value": "my-name1",
									"Key": "Name"
								}
							],
							"AmiLaunchIndex": 0
						}
					]
				},
				{
					"OwnerId": "123456789abc",
					"ReservationId": "r-88ef5d66",
					"Groups": [],
					"Instances": [
						{
							"State": {
								"Code": 80,
								"Name": "stopped"
							},
							"InstanceId": "i-abcdefg2",
							"Tags": [
								{
									"Value": "my-name2",
									"Key": "Name"
								}
							],
							"AmiLaunchIndex": 0
						}
					]
				}

			]
		}	
  eos
  }
  let(:vap_list_instance_ids) { "i-abcdefg1\ni-abcdefg2" }
  let(:var_list_instance_names) { "my-name1\nmy-name2" }

  before(:each) {
    @textout=double('outout')
    @shellout=double('ZAWS::Helper::Shell')
    @data_instance = ZAWS::AWSCLI::Data::EC2::Instance.new(@shellout, nil)
  }

  describe '#names_by_ids' do

    context 'the name/id data is loaded' do
      it 'returns instance ids as list of strings' do
        @data_instance.load(nil, vap_describe_instance, nil)
        expect(@data_instance.names_by_ids(vap_list_instance_ids)).to eq(var_list_instance_names)
      end
    end

    context 'in which the role policy has resources has no instance ids' do

    end

  end

end





