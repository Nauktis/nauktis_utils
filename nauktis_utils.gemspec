# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nauktis_utils/version'

Gem::Specification.new do |spec|
  spec.name          = "nauktis_utils"
  spec.version       = NauktisUtils::VERSION
  spec.authors       = ['Nauktis']
  spec.email         = ['']

  spec.summary       = %q{Various ruby utility classes.}
  spec.description   = %q{Various ruby utility classes and tools.}
  spec.homepage      = 'https://github.com/Nauktis/nauktis_utils'
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport'
  spec.add_dependency 'json'
  spec.add_dependency 'sha3'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "tmpdir"
end
