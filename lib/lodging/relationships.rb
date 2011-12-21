module BrighterPlanet
  module Lodging
    module Relationships
      def self.included(target)
        target.belongs_to :country,       :foreign_key => 'country_iso_3166_code'
        target.belongs_to :lodging_class, :foreign_key => 'lodging_class_name'
      end
    end
  end
end
