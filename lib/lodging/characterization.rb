module BrighterPlanet
  module Lodging
    module Characterization
      def self.included(base)
        base.characterize do
          has :rooms
          has :duration, :measures => :time
          has :zip_code
          has :state
          has :country
          has :lodging_class
          has :property_rooms
        end
      end
    end
  end
end
