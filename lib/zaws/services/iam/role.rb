require 'json'
require 'netaddr'
require 'timeout'

module ZAWS
  module Services
    module IAM
      class Role

        def initialize(shellout, aws)
          @shellout=shellout
          @aws=aws
        end

        def view_policy(role, policy, view, textout, verbose)
          @aws.awscli.command_iam.getRolePolicy.execute(role, policy, view, verbose)
          textout.puts(@aws.awscli.data_iam.role_policy.view())
        end

      end
    end
  end
end
