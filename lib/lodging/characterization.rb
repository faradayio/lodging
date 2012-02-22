module BrighterPlanet
  module Lodging
    module Characterization
      def self.included(base)
        base.characterize do
          has :date
          has :rooms
          has :duration, :measures => :time
          has :zip_code
          has :city
          has :state
          has :country
          has :lodging_class
          has :heating_degree_days
          has :cooling_degree_days
          has :property
          has :property_rooms
          has :property_floors
          has :property_construction_year
          has :property_ac_coverage
          has :property_fridge_coverage
          has :property_hot_tubs
          has :property_outdoor_pools
          has :property_indoor_pools
        end
      end
    end
  end
end
