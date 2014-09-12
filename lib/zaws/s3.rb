module ZAWS
  class S3

    def initialize(shellout,aws)
      @shellout=shellout
      @aws=aws
    end

    def bucket()
      @_bucket ||= (ZAWS::S3Services::Bucket.new(@shellout, @aws))
      return @_bucket
    end

  end
end