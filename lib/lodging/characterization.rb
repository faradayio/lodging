module BrighterPlanet
  module Lodging
    module Characterization
      def self.included(base)
        base.characterize do
          has :rooms
          has :duration, :measures => :time
          has :postcode
          has :zip_code
          has :city
          has :locality
          has :state
          has :country
          has :lodging_property_name
          has :lodging_class
          has :property_rooms
        end
      end
    end
  end
end
