require "thor"
Dir["#{File.dirname(__FILE__)}/zaws/**/*.rb"].each { |item| load(item) }

module ZAWS
  class ZAWSCLI < Thor

    attr_accessor :out

    def initialize(*args)
      super
      @out = $stdout
    end

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

    desc "nessus", "tennable nessus"
    subcommand "nessus", ZAWS::Command::Nessus

    desc "ai", "artificial intelligence"
    subcommand "ai", ZAWS::Command::AI

    desc "sumo", "sumologic"
    subcommand "sumo", ZAWS::Command::Sumo

    desc "newrelic", "newrelic"
    subcommand "newrelic", ZAWS::Command::Newrelic

    desc "config", "config"
    subcommand "config", ZAWS::Command::Config

    desc "version", "Get the version of the Zynx AWS Automation Tool."

    def version
      @out.puts "zaws version #{ZAWS::VERSION}"
    end

  end
end

