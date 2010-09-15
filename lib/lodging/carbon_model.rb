require 'leap'
require 'conversions'

module BrighterPlanet
  module Lodging
    module CarbonModel
      def self.included(base)
        base.extend ::Leap::Subject
        base.decide :emission, :with => :characteristics do
          committee :emission do # returns kg CO2e
            quorum 'from rooms, nights, and emission factor', :needs => [:rooms, :nights, :emission_factor] do |characteristics|
              characteristics[:rooms] * characteristics[:nights] * characteristics[:emission_factor]
            end
            
            quorum 'default' do
              raise "The emission committee's default quorum should never be called."
            end
          end
          
          committee :emission_factor do # returns kg CO2e per room night
            quorum 'from fuel intensities', :needs => [:natural_gas_intensity, :fuel_oil_intensity, :electricity_intensity, :district_heat_intensity] do |characteristics|
              natural_gas = FuelType.find_by_name "Commercial Natural Gas"
              fuel_oil = FuelType.find_by_name "Distillate Fuel Oil 2"
              electricity = ResidenceFuelType.find_by_name "electricity"
              
              # FIXME TODO won't need this once we convert emission factors to co2 / unit energy
              #   kg / J                           kg / cubic m     J / cubic m
              natural_gas_energy_ef = natural_gas.emission_factor / 38_339_000
              
              # FIXME TODO won't need this once we convert emission factors to co2 / unit energy
              #   kg / J                        kg / l           J / l
              fuel_oil_energy_ef = fuel_oil.emission_factor / 38_655_000
              
              # based on CA-CP calculator
              # assume district heat is 50% natural gas 50% distillate fuel
              # assume natural gas boilers 81.7% efficient; fuel oil boilers 84.6% efficient
              # assume 5% transmission loss
              district_heat_emission_factor = (((natural_gas_energy_ef / 0.817) / 2) + ((fuel_oil_energy_ef / 0.846) / 2)) / 0.95
              
              (characteristics[:natural_gas_intensity] * natural_gas.emission_factor) +
                (characteristics[:fuel_oil_intensity] * fuel_oil.emission_factor) +
                (characteristics[:electricity_intensity] * electricity.emission_factor) +
                (characteristics[:district_heat_intensity] * district_heat_emission_factor)
            end
          end
          
          committee :natural_gas_intensity do # returns cubic metres per room-night
            quorum 'from census division', :needs => :census_division do |characteristics|
              characteristics[:census_division].lodging_building_natural_gas_intensity
            end
            
            quorum 'from lodging class', :needs => :lodging_class do |characteristics|
              characteristics[:lodging_class].natural_gas_intensity
            end
          end
          
          committee :fuel_oil_intensity do # returns litres per room-night
            quorum 'from census division', :needs => :census_division do |characteristics|
              characteristics[:census_division].lodging_building_fuel_oil_intensity
            end
            
            quorum 'from lodging class', :needs => :lodging_class do |characteristics|
              characteristics[:lodging_class].fuel_oil_intensity
            end
          end
          
          committee :electricity_intensity do # returns kilowatt hours per room-night
            quorum 'from census division', :needs => :census_division do |characteristics|
              characteristics[:census_division].lodging_building_electricity_intensity
            end
            
            quorum 'from lodging class', :needs => :lodging_class do |characteristics|
              characteristics[:lodging_class].electricity_intensity
            end
          end
          
          committee :district_heat_intensity do # returns joules per room-night
            quorum 'from census division', :needs => :census_division do |characteristics|
              characteristics[:census_division].lodging_building_district_heat_intensity
            end
            
            quorum 'from lodging class', :needs => :lodging_class do |characteristics|
              characteristics[:lodging_class].district_heat_intensity
            end
          end
          
          committee :lodging_class do # returns the type of lodging
            quorum 'default' do
              LodgingClass.find_by_name 'Average'
            end
          end
          
          committee :census_division do # returns census division
            quorum 'from state', :needs => :state do |characteristics|
              characteristics[:state].census_division
            end
          end
          
          committee :state do # returns state
            quorum 'from zip code', :needs => :zip_code do |characteristics|
              characteristics[:zip_code].state
            end
          end
          
          committee :nights do # returns nights
            quorum 'default' do
              base.fallback.nights
            end
          end
          
          committee :rooms do # return rooms
            quorum 'default' do
              base.fallback.rooms
            end
          end
        end
      end
    end
  end
end
