# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "metacrunch/version"

Gem::Specification.new do |spec|
  spec.name          = "metacrunch"
  spec.version       = Metacrunch::VERSION
  spec.authors       = ["René Sprotte", "Michael Sievers", "Marcel Otto"]
  spec.summary       = %q{Data processing and ETL toolkit for Ruby}
  spec.homepage      = "http://github.com/ubpb/metacrunch"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "bundler",       ">= 1.11"
  spec.add_dependency "activesupport", ">= 4.2", "< 5.0"
  spec.add_dependency "commander",     "~> 4.4"
end
