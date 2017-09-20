# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "metacrunch/version"

Gem::Specification.new do |spec|
  spec.name          = "metacrunch"
  spec.version       = Metacrunch::VERSION
  spec.authors       = ["René Sprotte", "Michael Sievers", "Marcel Otto"]
  spec.email         = "r.sprotte@ub.uni-paderborn.de"
  spec.summary       = %q{Data processing and ETL toolkit for Ruby}
  spec.homepage      = "http://github.com/ubpb/metacrunch"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 5.1.0"
  spec.add_dependency "colorize",      ">= 0.8.1"
  spec.add_dependency "sequel",        ">= 5.0.0"
  spec.add_dependency "redis",         ">= 4.0.0"
end
