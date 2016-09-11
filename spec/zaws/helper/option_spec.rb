require 'spec_helper'

describe ZAWS::Helper::Option do

  describe "#absent" do
    it "absent options" do
      ZAWS::Helper::Option.absent([:option1, :option2], {:option1 => 'option1'}).should =~ [:option2]
    end

    it "no absent options" do
      ZAWS::Helper::Option.absent([:option1, :option2], {:option1 => 'option1', :option2 => 'option2'}).should =~ []
    end
  end

  describe "#exclusive?" do
    it "options not exclusive" do
      ZAWS::Helper::Option.exclusive?([:option1, :option2], {:option1 => 'option1', :option2 => 'option2'}).should be_false
    end

    it "option is exclusive" do
      ZAWS::Helper::Option.exclusive?([:option1, :option2], {:option1 => 'option1'}).should be_true
    end
  end

  describe "#exists?" do

    it "option exist" do
      ZAWS::Helper::Option.exists?([:option1], {:option1 => 'option1'}).should be_true
    end

    it "all options do not exist" do
      ZAWS::Helper::Option.exists?([:option1, :option2], {:option1 => 'option1'}).should be_false
    end

    it "all options exist" do
      ZAWS::Helper::Option.exists?([:option1, :option2], {:option1 => 'option1', :option2 => 'option2'}).should be_true
    end

  end

  describe "minimum?" do
    it "minimum of 1 option specified" do
      ZAWS::Helper::Option.minimum?(1, [:option1, :option2], {:option1 => 'option1'}).should be_true
    end

    it "minimum of 2 options not specified" do
      ZAWS::Helper::Option.minimum?(2, [:option1, :option2], {:option1 => 'option1'}).should be_false
    end

  end

end


