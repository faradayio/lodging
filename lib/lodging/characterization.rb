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
          has :lodging_class
          has :property_rooms do |pr|
            "The number of lodging rooms"
          end
          has :rooms_range do |rr| # don't really want user to enter this but need to conceal it in methodology display
            "A range of rooms"
          end
        end
      end
    end
  end
end
