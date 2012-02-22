module BrighterPlanet
  module Lodging
    module Data
      def self.included(base)
        base.col :date,     :type => :date
        base.col :rooms,    :type => :integer
        base.col :duration, :type => :integer
        base.col :zip_code_name
        base.col :city
        base.col :state_postal_abbreviation
        base.col :country_iso_3166_code
        base.col :lodging_class_name
        base.col :heating_degree_days, :type => :float
        base.col :cooling_degree_days, :type => :float
        base.col :property_northstar_id
        base.col :property_rooms,             :type => :integer
        base.col :property_floors,            :type => :integer
        base.col :property_construction_year, :type => :integer
        base.col :property_ac_coverage,       :type => :float
        base.col :property_fridge_coverage,   :type => :float
        base.col :property_hot_tubs,          :type => :integer
        base.col :property_outdoor_pools,     :type => :integer
        base.col :property_indoor_pools,      :type => :integer
        
        base.data_miner do
          process 'pull orphans' do
            Fuel.run_data_miner!
          end
        end
      end
    end
  end
end
