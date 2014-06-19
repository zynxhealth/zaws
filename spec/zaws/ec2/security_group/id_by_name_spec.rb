require 'spec_helper'

describe ZAWS::EC2 do

  it "security group id by group name" do

	sgroups = <<-eos
	  {
		  "SecurityGroups": [
			  {
				  "Description": "My security group",
				  "GroupName": "my_security_group_name",
				  "OwnerId": "123456789012",
				  "GroupId": "sg-abcd1234"
			  }
		  ]
	  }
	eos

	textout=double('outout')
	shellout=double('ZAWS::Helper::Shell')
	expect(shellout).to receive(:cli).with("aws --output json --region us-west-1 ec2 describe-security-groups --filter 'Name=vpc-id,Values=my_vpc_id' 'Name=group-name,Values=my_security_group_name'",nil).and_return(sgroups)
	expect(textout).to receive(:puts).with('sg-abcd1234')
	aws=ZAWS::AWS.new(shellout)
	aws.ec2.security_group.id_by_name('us-west-1',textout,nil,'my_vpc_id','my_security_group_name')

  end

end



