# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "lodging/version"

Gem::Specification.new do |s|
  s.name = %q{lodging}
  s.version = BrighterPlanet::Lodging::VERSION

  s.authors = ["Andy Rossmeissl", "Seamus Abshere", "Ian Hough", "Matt Kling", "Derek Kastner"]
  s.date = "2012-05-16"
  s.summary = %q{A carbon model}
  s.description = %q{A software model in Ruby for the greenhouse gas emissions of a lodging}
  s.email = %q{andy@rossmeissl.net}
  s.homepage = %q{https://github.com/brighterplanet/lodging}

  s.extra_rdoc_files = [
    "LICENSE",
     "LICENSE-PREAMBLE",
     "README.rdoc"
  ]
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_runtime_dependency 'earth', '~>0.12.4'
  s.add_dependency 'emitter', '~> 1.0.0'
  s.add_runtime_dependency 'fuzzy_infer', '>=0.0.2'
  s.add_development_dependency 'mysql2'
  s.add_development_dependency 'sniff', '~> 1.0.0'
end
