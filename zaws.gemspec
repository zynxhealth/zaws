# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zaws/version'

Gem::Specification.new do |spec|
  spec.name          = "zaws"
  spec.version       = ZAWS::VERSION
  spec.authors       = ["Aslan Brooke"]
  spec.email         = ["aslandbrooke@yahoo.com"]
  spec.description   = %q{the zaws gem provides command line tools for interfacing with AWS through the AWS CLI. It is required that the AWS CLI be installed on the system that this gem is used on. This gem expects the AWS credentials to be located in a location that the AWS CLI can access them, whether it be environment variables or config file.}
  spec.summary       = %q{Zynx AWS Automation Tool}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "thor", "~> 0.18.1"
  spec.add_runtime_dependency "netaddr", "~> 1.5.0"
  spec.add_runtime_dependency "mixlib-shellout", "~> 1.1.0"
  spec.add_runtime_dependency "json", "~> 1.5.0"

  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14.1"
  spec.add_development_dependency "cucumber", "~> 1.3.14"
  spec.add_development_dependency "aruba", "~> 0.5.4"
  spec.add_development_dependency "aruba-doubles", "~> 1.2.1"

end
