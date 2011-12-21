module BrighterPlanet
  module Lodging
    module Data
      def self.included(base)
        base.col :rooms,    :type => :integer
        base.col :duration, :type => :integer
        base.col :zip_code_name
        base.col :state_postal_abbreviation
        base.col :country_iso_3166_code
        base.col :lodging_class_name
        base.col :property_rooms, :type => :integer
        
        base.data_miner do
          process 'pull orphans' do
            Fuel.run_data_miner!
          end
        end
      end
    end
  end
end