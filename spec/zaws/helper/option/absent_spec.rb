require 'spec_helper'

describe ZAWS::Helper::Option do

  it "absent options" do
	ZAWS::Helper::Option.absent([:option1,:option2],{:option1=>'option1'}).should =~ [:option2] 
  end

  it "no absent options" do
	ZAWS::Helper::Option.absent([:option1,:option2],{:option1=>'option1',:option2=>'option2'}).should =~ []
  end

end

