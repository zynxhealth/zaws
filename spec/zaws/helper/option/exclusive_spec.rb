require 'spec_helper'

describe ZAWS::Helper::Option do

  it "options not exclusive" do
    ZAWS::Helper::Option.exclusive?([:option1,:option2],{:option1=>'option1',:option2=>'option2'}).should be_false
  end

  it "option is exclusive" do
    ZAWS::Helper::Option.exclusive?([:option1,:option2],{:option1=>'option1'}).should be_true
  end

end

