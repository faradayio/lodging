require 'emitter'

module BrighterPlanet
  module Lodging
    extend BrighterPlanet::Emitter

    def self.lodging_model
      if Object.const_defined? 'Lodging'
        ::Lodging
      elsif Object.const_defined? 'LodgingRecord'
        LodgingRecord
      else
        raise 'There is no lodging model'
      end
    end
  end
end