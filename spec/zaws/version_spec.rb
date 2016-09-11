require 'spec_helper'

describe ZAWS::ZAWSCLI do

  describe "#version" do

    it "Get zaws version." do
      @shellout=double('ZAWS::Helper::Shell')
      zaws=ZAWS::ZAWSCLI.new
      zaws.out=@shellout
      expect(@shellout).to receive(:puts).with("zaws version #{ZAWS::VERSION}")
      zaws.version
    end
  end

end


