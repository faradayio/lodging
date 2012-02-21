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
          has :property_name
          has :property
          has :property_rooms
          has :property_floors
          has :property_construction_year
          has :property_ac_coverage
          has :property_fridge_coverage
          has :property_hot_tub_count
          has :property_outdoor_pool_count
          has :property_indoor_pool_count
        end
      end
    end
  end
end
