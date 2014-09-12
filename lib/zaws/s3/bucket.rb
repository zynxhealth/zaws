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

      def get(region,bucket_name,dest)
        dir = dest ? dest : Dir.mktmpdir()
        puts "bucket #{bucket_name}"
        puts "dir #{dir}"
        comLine = "aws s3 cp #{bucket_name} #{dir} --region #{region} --recursive"
        puts @shellout.cli(comLine, nil)

        dir
      end

    end
  end
end