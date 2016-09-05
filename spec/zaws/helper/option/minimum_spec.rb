require 'spec_helper'

describe ZAWS::Helper::Option do

  it "minimum of 1 option specified" do
    ZAWS::Helper::Option.minimum?(1,[:option1,:option2],{:option1=>'option1'}).should be_true
  end

  it "minimum of 2 options not specified" do
    ZAWS::Helper::Option.minimum?(2,[:option1,:option2],{:option1=>'option1'}).should be_false
  end

end

