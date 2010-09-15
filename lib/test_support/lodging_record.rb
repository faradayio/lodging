require 'active_record'
require 'falls_back_on'
require 'lodging'
require 'sniff'

class LodgingRecord < ActiveRecord::Base
  include Sniff::Emitter
  include BrighterPlanet::Lodging

  belongs_to :lodging_class, :foreign_key => 'lodging_class_name'
  belongs_to :zip_code,      :foreign_key => 'zip_code_name'
  belongs_to :state,         :foreign_key => 'state_postal_abbreviation'

  falls_back_on :rooms  => 1,
                :nights => 1
end
