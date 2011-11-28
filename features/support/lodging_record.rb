require 'lodging'

class LodgingRecord < ActiveRecord::Base
  include BrighterPlanet::Emitter
  include BrighterPlanet::Lodging
end
