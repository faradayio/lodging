require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "lodging"
    gem.summary = %Q{A carbon model}
    gem.description = %Q{A software model in Ruby for the greenhouse gas emissions of a lodging}
    gem.email = "andy@rossmeissl.net"
    gem.homepage = "http://github.com/brighterplanet/lodging"
    gem.authors = ["Andy Rossmeissl"]
    gem.test_files = Dir.glob(File.join('features', '**', '*.rb')) +
      Dir.glob(File.join('features', '**', '*.feature')) +
      Dir.glob(File.join('lib', 'test_support', '**/*.rb'))
    gem.add_development_dependency 'activerecord', '~>3.0.0.beta4'
    gem.add_development_dependency 'bundler', '~>1.0.0.beta.2'
    gem.add_development_dependency 'cucumber', '~>0.8.3'
    gem.add_development_dependency 'jeweler', '~>1.4.0'
    gem.add_development_dependency 'rake'
    gem.add_development_dependency 'rdoc'
    gem.add_development_dependency 'sniff', '~>0.1.12' unless ENV['LOCAL_SNIFF']
    gem.add_dependency 'emitter', '~>0.0.6' unless ENV['LOCAL_EMITTER']
    gem.add_dependency 'earth', '~>0.0.37' unless ENV['LOCAL_EARTH']
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

unless ENV['NOBUNDLE']
  begin
    require 'sniff'
    require 'sniff/rake_task'
    Sniff::RakeTask.new(:console) do |t|
      t.earth_domains = :industry
    end
  rescue LoadError
    puts 'Sniff gem not found, sniff tasks unavailable'
  end

  require 'cucumber'
  require 'cucumber/rake/task'
  
  desc 'Run all cucumber tests'
  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "features --format pretty"
  end
  
  desc "Run all tests with RCov"
  Cucumber::Rake::Task.new(:features_with_coverage) do |t|
    t.cucumber_opts = "features --format pretty"
    t.rcov = true
    t.rcov_opts = ['--exclude', 'features']
  end
  
  task :test => :features
  task :default => :features
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "lodging #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
