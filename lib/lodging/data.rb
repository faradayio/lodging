module BrighterPlanet
  module Lodging
    module Data
      def self.included(base)
        base.data_miner do
          schema do
            string  'lodging_class_name'
            string  'zip_code_name'
            string  'state_postal_abbreviation'
            integer 'rooms'
            integer 'duration'
          end

          process :run_data_miner_on_belongs_to_associations
        end
      end
    end
  end
end
