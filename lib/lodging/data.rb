module BrighterPlanet
  module Lodging
    module Data
      def self.included(base)
        base.force_schema do
          string  'lodging_class_name'
          string  'zip_code_name'
          string  'state_postal_abbreviation'
          integer 'rooms'
          integer 'duration'
        end

        base.data_miner do
          process 'pull orphans' do
            Fuel.run_data_miner!
          end
        end
      end
    end
  end
end
