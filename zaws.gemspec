# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zaws/version'

Gem::Specification.new do |spec|
  spec.name          = "zaws"
  spec.version       = Zaws::VERSION
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

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14.1"

end
