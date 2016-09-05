require 'spec_helper'

describe ZAWS::Helper::Option do

  it "option exist" do
	ZAWS::Helper::Option.exists?([:option1],{:option1=>'option1'}).should be_true
  end

  it "all options do not exist" do
	ZAWS::Helper::Option.exists?([:option1,:option2],{:option1=>'option1'}).should be_false
  end

  it "all options exist" do
	ZAWS::Helper::Option.exists?([:option1,:option2],{:option1=>'option1',:option2=>'option2'}).should be_true
  end

end

