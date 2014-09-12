module ZAWS
  module S3Services
    class Bucket

      def initialize(shellout,aws)
        @shellout=shellout
        @aws=aws
      end

      def view(name,region,textout=nil)
        cmdline="aws --region #{region} s3 ls"
        bucket_list=@shellout.cli cmdline
        textout.puts(bucket_list) if textout
        return bucket_list
      end

      def exists(name,region,textout=nil)
        return /\s#{name}$/.match(view(name,region,nil)) != nil
      end

      def declare(name,region,textout)
        if exists(name,region,nil)
          textout.puts "Bucket already exists. Creation skipped.\n"
        else
          cmdline="aws --region #{region} s3 mb s3://#{name}"
          response=@shellout.cli cmdline
          error_match=/^make_bucket\sfailed:\s(?<msg>)$/.match(response)
          textout.puts("#{error_match[:msg]}") if error_match != nil
          return 1 if /^make_bucket failed: /.match(response) != nil
        end
        textout.puts "Bucket created.\n"
        return 0
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