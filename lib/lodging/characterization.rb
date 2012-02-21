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
        end
      end
    end
  end
end
