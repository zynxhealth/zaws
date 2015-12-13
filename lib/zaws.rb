# require "zaws/version"
# require "zaws/helper/option"
# require "zaws/helper/output"
# require "zaws/helper/shell"
# require "zaws/helper/zfile"
# require "zaws/command/subnet"
# require "zaws/command/security_group"
# require "zaws/command/route_table"
# require "zaws/command/compute"
# require "zaws/command/elasticip"
# require "zaws/command/load_balancer"
# require "zaws/command/hosted_zone"
# require "zaws/command/cloud_trail"
# require "zaws/command/bucket"
# require "zaws/aws"
# require "zaws/cloud_trail"
# require "zaws/ec2"
# require "zaws/elb"
# require "zaws/route53"
# require "zaws/s3"
# require "zaws/ec2/subnet"
# require "zaws/ec2/security_group"
# require "zaws/ec2/route_table"
# require "zaws/ec2/compute"
# require "zaws/ec2/elasticip"
# require "zaws/elb/load_balancer"
# require "zaws/route53/hosted_zone"
# require "zaws/s3/bucket"
require "thor"
#require "zaws/awscli"
Dir["#{File.dirname(__FILE__)}/zaws/**/*.rb"].each { |item| load(item) }

module ZAWS
  class ZAWSCLI < Thor

    desc "subnet", "ec2 subnet(s)"
    subcommand "subnet", ZAWS::Command::Subnet

    desc "security_group", "ec2 security group(s)"
    subcommand "security_group", ZAWS::Command::Security_Group

    desc "route_table", "ec2 route table(s)"
    subcommand "route_table", ZAWS::Command::Route_Table

    desc "compute", "ec2 compute instance(s)"
    subcommand "compute", ZAWS::Command::Compute

    desc "elasticip", "ec2 elasticip(s)"
    subcommand "elasticip", ZAWS::Command::Elasticip

    desc "load_balancer", "elb load balancer(s)"
    subcommand "load_balancer", ZAWS::Command::Load_Balancer

    desc "hosted_zone", "elb hosted_zone(s)"
    subcommand "hosted_zone", ZAWS::Command::Hosted_Zone

    desc "cloud_trail", "aws cloud trail"
    subcommand "cloud_trail", ZAWS::Command::CloudTrail

    desc "bucket", "S3 storage bucket(s)"
    subcommand "bucket", ZAWS::Command::Bucket

    desc "iam", "iam access control"
    subcommand "iam", ZAWS::Command::IAM

    desc "vpc", "virtual private cloud (or vpc)"
    subcommand "vpc", ZAWS::Command::VPC

    desc "version", "Get the version of the Zynx AWS Automation Tool."

    def version
      puts "zaws version #{ZAWS::VERSION}"
    end

  end
end

