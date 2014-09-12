module ZAWS
  module S3Services
    class Bucket

      def initialize(shellout, aws)
        @shellout=shellout
        @aws=aws
      end

      def declare(bucket_name,textout)
        textout.puts "Bucket already exists. Creation skipped.\n"
      end

    end
  end
end