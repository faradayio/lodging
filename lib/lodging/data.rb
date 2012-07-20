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
        base.col :heating_degree_days, :type => :float
        base.col :cooling_degree_days, :type => :float
        base.col :property_northstar_id
        base.col :property_rooms,        :type => :integer
        base.col :floors,                :type => :integer
        base.col :construction_year,     :type => :integer
        base.col :ac_coverage,           :type => :float
        base.col :refrigerator_coverage, :type => :float
        base.col :hot_tubs,              :type => :integer
        base.col :outdoor_pools,         :type => :integer
        base.col :indoor_pools,          :type => :integer
        
        base.data_miner do
          process 'pull orphans' do
            Fuel.run_data_miner!
          end
        end
      end
    end
  end
end
