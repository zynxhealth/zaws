require 'spec_helper'

describe ZAWS::Helper::ProcessHash do

  describe "#keep" do
    context "provided hash with no value matching list of values" do
      it "returns empty string" do
        expect(ZAWS::Helper::ProcessHash.keep({"root" => "value"}, ["test"])).to eql("")
      end
    end
    context "provided hash with  value matching list of values" do
      it "returns hash" do
        expect(ZAWS::Helper::ProcessHash.keep({"root" => "value"}, ["value"])).to eql({"root" => "value"})
      end
    end
    context "provided hash with no value matching list of values at any level" do
      it "returns empty string" do
        expect(ZAWS::Helper::ProcessHash.keep({"root" => {"value" => "again"}}, ["test"])).to eql("")
      end
    end
    context "provided hash with value matching list at second level" do
      it "returns hash" do
        expect(ZAWS::Helper::ProcessHash.keep({"root" => {"value" => "again"}}, ["again"])).to eql({"root" => {"value" => "again"}})
      end
    end
    context "provided hash with value matching list at second level, but not in other branch" do
      it "returns matching branch hash" do
        expect(ZAWS::Helper::ProcessHash.keep({"root" => {"value" => "again", "not-matching" => {"branch" => "cut-off"}}}, ["again"])).to eql({"root" => {"value" => "again"}})
      end
    end
    context "provided hash with value matching list at second level, but not in other branch" do
      it "returns matching branch hash" do
        expect(ZAWS::Helper::ProcessHash.keep({"root" => {"value" => "again", "not-matching" => {"branch" => "cut-off"}}}, ["root"])).to eql({"root" => {"value" => "again", "not-matching" => {"branch" => "cut-off"}}})
      end
    end
    context "provided array of hash with value matching leafs" do
      it "returns matching array of hash" do
        expect(ZAWS::Helper::ProcessHash.keep({"root" => [{"root" => "easy1"}, {"root" => "easy2"}]}, ["easy"])).to eql({"root" => [{"root" => "easy1"}, {"root" => "easy2"}]})
      end
    end
    context "provided array of hash with value matching leafs, and one of the leafs is an array" do
      it "returns matching array of hash with array" do
        expect(ZAWS::Helper::ProcessHash.keep({"root" => [{"root" => "easy1"}, {"root" => ["easy2","nope"]}]}, ["easy"])).to eql({"root" => [{"root" => "easy1"}, {"root" => ["easy2"]}]})
      end
    end
  end
end

