require 'active_record'
require 'falls_back_on'
require 'lodging'
require 'sniff'

class LodgingRecord < ActiveRecord::Base
  include Sniff::Emitter
  include BrighterPlanet::Lodging
end
