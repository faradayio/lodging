require 'bundler'
Bundler.setup

require 'cucumber'
require 'cucumber/formatter/unicode'
require 'rspec'
require 'rspec/expectations'
require 'cucumber/rspec/doubles'

require 'data_miner'
DataMiner.logger = Logger.new(nil)

require 'sniff'

Sniff.init File.join(File.dirname(__FILE__), '..', '..'),
  :adapter => 'mysql2',
  :database => 'test_lodging',
  :username => 'root',
  :password => 'password',
  :earth => [:hospitality, :fuel, :locality],
  :cucumber => true,
  :logger => 'log/test_log.txt'

require_relative './lodging_property'
