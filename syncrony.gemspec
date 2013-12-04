# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'syncrony/version'

Gem::Specification.new do |spec|
  spec.name          = "syncrony"
  spec.version       = Syncrony::VERSION
  spec.authors       = ["Joseph Glanville"]
  spec.email         = ["joseph@cloudscaling.com"]
  spec.description   = %q{Syncrony is a set of distributed systems primitives built with Celluloid and Etcd.}
  spec.summary       = %q{Syncrony distributed systems toolkit}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # Development dependencies
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"

  # Runtime dependencies
  spec.add_runtime_dependency "celluloid"
#  spec.add_runtime_dependency "etcd-rb", "~> 1.0.0.pre1"
end
