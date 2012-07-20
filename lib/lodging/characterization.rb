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
          has :heating_degree_days
          has :cooling_degree_days
          has :property do |prop|
            prop.name
          end
          has :property_rooms
          has :floors
          has :construction_year
          has :ac_coverage
          has :refrigerator_coverage
          has :hot_tubs
          has :outdoor_pools
          has :indoor_pools
        end
      end
    end
  end
end
