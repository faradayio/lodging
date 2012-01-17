module BrighterPlanet
  module Lodging
    module Characterization
      def self.included(base)
        base.characterize do
          has :date
          has :rooms
          has :duration, :measures => :time
          # has :postcode
          has :zip_code
          has :city
          # has :locality
          has :state
          has :country
          has :lodging_property_name
          has :property_rooms
          has :property_construction_year
          has :lodging_class
        end
      end
    end
  end
end
