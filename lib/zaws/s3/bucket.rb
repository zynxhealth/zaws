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
        bucket_list
      end

      def exists(name,region,textout=nil)
        /\s#{name}$/.match(view(name,region,nil)) != nil
      end

      def declare(name,region,textout)
        if exists(name,region,nil)
          puts "Bucket already exists. Creation skipped.\n"
        else
          cmdline="aws --region #{region} s3 mb s3://#{name}"
          puts @shellout.cli(cmdline,textout)
        end
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