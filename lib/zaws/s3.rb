module ZAWS
  class S3

    def initialize(shellout,aws)
      @shellout=shellout
      @aws=aws
    end

    def bucket()
      @_bucket ||= (ZAWS::Services::S3::Bucket.new(@shellout, @aws))
      return @_bucket
    end

  end
end