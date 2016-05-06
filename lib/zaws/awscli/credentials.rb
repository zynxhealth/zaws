module ZAWS
  class AWSCLI
    class Credentials
      def initialize(shellout, aws, filename)
        @shellout=shellout
        @aws=aws
        @awsconfig=Inifile.new(filename)
      end

      def profiles
        @awsconfig.sections
      end

      def access_key(profile)
        @awsconfig.to_h()[profile]['aws_access_key_id']
      end

      def secret_key(profile)
        @awsconfig.to_h()[profile]['aws_secret_access_key']
      end

    end
  end
end
