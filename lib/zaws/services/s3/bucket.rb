module ZAWS
  module Services
    module S3
      class Bucket

        def initialize(shellout, aws)
          @shellout=shellout
          @aws=aws
        end

        def view(name, region, verbose=nil)
          cmdline="aws --region #{region} s3 ls"
          bucket_list=@shellout.cli cmdline
          verbose.puts(bucket_list) if verbose
          bucket_list
        end

        def exists(name, region, verbose=nil)
          /\s#{name}$/.match(view(name, region, verbose)) != nil
        end

        def declare(name, region, verbose)
          if exists(name, region, nil)
            puts "Bucket already exists. Creation skipped.\n"
          else
            cmdline="aws --region #{region} s3 mb s3://#{name}"
            puts @shellout.cli(cmdline, verbose)
          end
        end

        def sync(region, bucket_name, dest, verbose=nil)
          dir = dest ? dest : Dir.mktmpdir
          com_line = "aws s3 sync #{bucket_name} #{dir} --region #{region}"
          puts @shellout.cli(com_line, verbose)

          dir
        end

      end
    end
  end
end