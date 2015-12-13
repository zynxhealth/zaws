require 'json'
require 'netaddr'
require 'timeout'

module ZAWS
  module Services
    module IAM
      class Policy

        def initialize(shellout, aws)
          @shellout=shellout
          @aws=aws
        end

        def view_default_policy_version(policy_arn, view, textout, verbose)
          @aws.awscli.command_iam.getPolicy.execute(policy_arn, 'json', verbose)
          version=@aws.awscli.data_iam.policy.defaultVersion
          @aws.awscli.command_iam.getPolicyVersion.execute(policy_arn, version, view, verbose)
          textout.puts(@aws.awscli.data_iam.policy_version.view()) if textout
        end

      end
    end
  end
end
