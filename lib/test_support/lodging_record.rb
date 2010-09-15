require 'active_record'
require 'falls_back_on'
require 'lodging'
require 'sniff'

class LodgingRecord < ActiveRecord::Base
  include Sniff::Emitter
  include BrighterPlanet::Lodging

  belongs_to :lodging_class

  falls_back_on :rooms  => 1,
                :nights => 1
end
