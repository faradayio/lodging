# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{lodging}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andy Rossmeissl"]
  s.date = %q{2010-09-09}
  s.description = %q{A software model in Ruby for the greenhouse gas emissions of a lodging}
  s.email = %q{andy@rossmeissl.net}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "Gemfile",
     "Gemfile.lock",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "dot.rvmrc",
     "features/lodging_committees.feature",
     "features/lodging_emissions.feature",
     "features/support/env.rb",
     "lib/lodging.rb",
     "lib/lodging/carbon_model.rb",
     "lib/lodging/characterization.rb",
     "lib/lodging/data.rb",
     "lib/lodging/summarization.rb",
     "lib/test_support/db/schema.rb",
     "lib/test_support/lodging_record.rb",
     "lodging.gemspec"
  ]
  s.homepage = %q{http://github.com/brighterplanet/lodging}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A carbon model}
  s.test_files = [
    "features/support/env.rb",
     "features/lodging_committees.feature",
     "features/lodging_emissions.feature",
     "lib/test_support/db/schema.rb",
     "lib/test_support/lodging_record.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_development_dependency(%q<cucumber>, ["~> 0.8.3"])
      s.add_development_dependency(%q<sniff>, ["~> 0.1.12"])
      s.add_runtime_dependency(%q<emitter>, ["~> 0.0.6"])
    else
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_dependency(%q<cucumber>, ["~> 0.8.3"])
      s.add_dependency(%q<sniff>, ["~> 0.1.12"])
      s.add_dependency(%q<emitter>, ["~> 0.0.6"])
    end
  else
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    s.add_dependency(%q<cucumber>, ["~> 0.8.3"])
    s.add_dependency(%q<sniff>, ["~> 0.1.12"])
    s.add_dependency(%q<emitter>, ["~> 0.0.6"])
  end
end

