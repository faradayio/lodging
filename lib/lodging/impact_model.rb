# Copyright © 2010 Brighter Planet.
# See LICENSE for details.
# Contact Brighter Planet for dual-license arrangements.

## Lodging impact model
# This model is used by the [Brighter Planet](http://brighterplanet.com) [CM1 web service](http://carbon.brighterplanet.com) to calculate the impacts of a lodging (e.g. a hotel stay), such as energy use, greenhouse gas emissions, and water use.

##### Timeframe
# The model calculates impacts that occured during a particular time period (`timeframe`).
# For example if the `timeframe` is February 2010, a lodging that occurred (`date`) on February 15, 2010 will have impacts, but a lodging that occurred on January 31, 2010 will have zero impacts.
#
# The default `timeframe` is the current calendar year.

##### Calculations
# The final impacts are the result of the calculations below. These are performed in reverse order, starting with the last calculation listed and finishing with the greenhouse gas emissions calculation.
#
# Each calculation listing shows:
#
# * value returned (*units of measurement*)
# * description of the value
# * calculation methods, listed from most to least preferred
#
# Some methods use `values` returned by prior calculations. If any of these `values` are unknown the method is skipped.
# If all the methods for a calculation are skipped, the value the calculation would return is unknown.

##### Standard compliance
# When compliance with a particular standard is requested, all methods that do not comply with that standard are ignored.
# Thus any `values` a method needs will have been calculated using a compliant method or will be unknown.
# To see which standards a method complies with, look at the `:complies =>` section of the code in the right column.
#
# Client input complies with all standards.

##### Collaboration
# Contributions to this impact model are actively encouraged and warmly welcomed. This library includes a comprehensive test suite to ensure that your changes do not cause regressions. All changes should include test coverage for new functionality. Please see [sniff](https://github.com/brighterplanet/sniff#readme), our emitter testing framework, for more information.
module BrighterPlanet
  module Lodging
    module ImpactModel
      def self.included(base)
        base.decide :impact, :with => :characteristics do
          # * * *
          
          #### Carbon (*kg CO<sub>2</sub>e*)
          # *The lodging's total anthropogenic greenhouse gas emissions during `timeframe`.*
          committee :carbon do
            # Divide `duration` (*seconds*) by 86,400 (*seconds / night*) and multiply by `rooms` to give *room-nights*.
            # Multiply by `emission factor` (*kg CO<sub>2</sub>e / room-night*) to give *kg CO<sub>2</sub>e.
            quorum 'from rooms, duration, and emission factor', :needs => [:rooms, :duration, :emission_factor], 
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:rooms] * characteristics[:duration] / 86400.0 * characteristics[:emission_factor]
            end
          end
          
          #### Emission factor (*kg CO<sub>2</sub>e / room-night*)
          # *Greenhouse gas emissions per occupied room per night.*
          committee :emission_factor do
            # Calculate an energy-based emission factor for [natural gas](http://data.brighterplanet.com/fuels) by dividing its `co2 emission factor` (*kg / cubic m*) by its `energy content` (*MJ / cubic m*) to give *kg CO<sub>2</sub> / MJ*
            # Calculate an energy-based emission factor for [fuel oil](http://data.brighterplanet.com/fuels) by dividing its `co2 emission factor` (*kg / l*) by its `energy content` (*MJ / l*) to give *kg CO<sub>2</sub> / MJ*
            # Calculate an energy-based emission factor for district heat by dividing the energy-based natural gas emission factor by 0.817 and the energy-based fuel oil emission factor by 0.846 (to account for boiler inefficiencies), averaging the two, and dividing by 0.95 (to account for transmission losses) to give *kg CO<sub>2</sub> / MJ*
            # Calculate an electricity emission factor by dividing the [eGRID subregion](http://data.brighterplanet.com/egrid_subregions) electricity emission factor by 1 - the [eGRID region](http://data.brighterplanet.com/egrid_regions) loss factor (to account for transmission and distribution losses) to give *kg CO<sub>2</sub> / kWh*
            # Multiply `natural gas intensity` (*cubic m / room-night*) by the volume-based natural gas emission factor (*kg CO<sub>2</sub> / room-night*), `fuel oil intensity` (*l / room-night*) by the volume-based fuel oil emission factor (*kg CO<sub>2</sub> / l*), `electricity intensity` (*kWh / room-night*) by the electricity emission factor (*kg CO<sub>2</sub> / kWh*), and `district heat intensity` (*MJ / room-night*) by the energy-based district heat emission factor (*kg CO<sub>2</sub> / MJ*), and add these together to give *kg CO<sub>2</sub> / room-night*.
            quorum 'from fuel intensities and eGRID', :needs => [:natural_gas_intensity, :fuel_oil_intensity, :electricity_intensity, :district_heat_intensity, :egrid_subregion, :egrid_region],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                natural_gas = Fuel.find_by_name "Pipeline Natural Gas"
                natural_gas_energy_ef = natural_gas.co2_emission_factor / natural_gas.energy_content
                
                fuel_oil = Fuel.find_by_name "Distillate Fuel Oil No. 2"
                fuel_oil_energy_ef = fuel_oil.co2_emission_factor / fuel_oil.energy_content
                
                district_heat_ef = (((natural_gas_energy_ef / 0.817) + (fuel_oil_energy_ef / 0.846)) / 2) / 0.95 # kg / MJ
                
                electricity_ef = characteristics[:egrid_subregion].electricity_emission_factor / (1 - characteristics[:egrid_region].loss_factor)
                
                (characteristics[:natural_gas_intensity] * natural_gas.co2_emission_factor) +
                (characteristics[:fuel_oil_intensity] * fuel_oil.co2_emission_factor) +
                (characteristics[:district_heat_intensity] * district_heat_ef) +
                (characteristics[:electricity_intensity] * electricity_ef)
            end
          end
          
          #### Natural gas intensity (*cubic m / room-night*)
          # *Natural gas use per occupied room per night.*
          committee :natural_gas_intensity do
            # Look up the [census division](http://data.brighterplanet.com/census_divisions) `natural gas intensity` (*cubic m / room-night*).
            quorum 'from census division', :needs => :census_division, 
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:census_division].lodging_building_natural_gas_intensity
            end
            
            # Otherwise look up the [lodging class](http://data.brighterplanet.com/lodging_class) `natural gas intensity` (*cubic m / room-night*).
            quorum 'from lodging class', :needs => :lodging_class,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:lodging_class].natural_gas_intensity
            end
          end
          
          #### Fuel oil intensity (*l / room-night*)
          # *Fuel oil use per occupied room per night.*
          committee :fuel_oil_intensity do
            # Look up the [census division](http://data.brighterplanet.com/census_divisions) `fuel oil intensity` (*l / room-night*).
            quorum 'from census division', :needs => :census_division,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:census_division].lodging_building_fuel_oil_intensity
            end
            
            # Otherwise look up the [lodging class](http://data.brighterplanet.com/lodging_class) `fuel oil intensity` (*l / room-night*).
            quorum 'from lodging class', :needs => :lodging_class,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:lodging_class].fuel_oil_intensity
            end
          end
          
          #### Electricity intensity (*kWh / room-night*)
          # *Electricity use per occupied room per night.*
          committee :electricity_intensity do
            # Look up the [census division](http://data.brighterplanet.com/census_divisions) `electricity intensity` (*kWh / room-night*).
            quorum 'from census division', :needs => :census_division,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:census_division].lodging_building_electricity_intensity
            end
            
            # Otherwise look up the [lodging class](http://data.brighterplanet.com/lodging classes) `electricity intensity` (*kWh / room-night*).
            quorum 'from lodging class', :needs => :lodging_class,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:lodging_class].electricity_intensity
            end
          end
          
          #### District heat intensity (*MJ / room-night*)
          # *District heat use per occupied room per night.*
          committee :district_heat_intensity do
            # Look up the [census division](http://data.brighterplanet.com/census_divisions) `district heat intensity` (*MJ / room-night*).
            quorum 'from census division', :needs => :census_division,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:census_division].lodging_building_district_heat_intensity
            end
            
            # Look up the [lodging class](http://data.brighterplanet.com/lodging_classes) `district heat intensity` (*MJ / room-night*).
            quorum 'from lodging class', :needs => :lodging_class,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:lodging_class].district_heat_intensity
            end
          end
          
          #### Lodging class
          # *The [lodging class](http://data.brighterplanet.com/lodging_classes).*
          committee :lodging_class do
            # Use client input, if available.
            
            # Otherwise use an artificial [lodging class](http://data.brighterplanet.com/lodging_classes) that represents the U.S. average.
            quorum 'default',
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do
                LodgingClass.find_by_name 'Average'
            end
          end
          
          #### eGRID region
          # *The lodging's [eGRID region](http://data.brighterplanet.com/egrid_regions).*
          committee :egrid_region do
            # Look up the [eGRID subregion](http://data.brighterplanet.com/egrid_subregions) `eGRID region`.
            quorum 'from eGRID subregion', :needs => :egrid_subregion,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:egrid_subregion].egrid_region
            end
          end
          
          #### eGRID subregion
          # *The lodging's [eGRID subregion](http://data.brighterplanet.com/egrid_subregions).*
          committee :egrid_subregion do
            # Look up the [zip code](http://data.brighterplanet.com/zip_codes) `eGRID subregion`.
            quorum 'from zip code', :needs => :zip_code,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:zip_code].egrid_subregion
            end
            
            # Otherwise use an artificial [eGRID subregion](http://data.brighterplanet.com/egrid_subregions) that represents the U.S. average.
            quorum 'default', :complies => [:ghg_protocol_scope_3, :iso, :tcr] do
              EgridSubregion.find_by_abbreviation 'US'
            end
          end
          
          #### Census division
          # *The lodging's [census division](http://data.brighterplanet.com/census_divisions).*
          committee :census_division do
            # Look up the [state](http://data.brighterplanet.com/states) `census division`.
            quorum 'from state', :needs => :state,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:state].census_division
            end
          end
          
          #### State
          # *The lodging's [state](http://data.brighterplanet.com/states).*
          committee :state do
            # Look up the [zip code](http://data.brighterplanet.com/zip_codes) `state`.
            quorum 'from zip code', :needs => :zip_code,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:zip_code].state
            end
          end
          
          #### Zip code
          # *The lodging's [zip code](http://data.brighterplanet.com/zip_codes).*
          # Use client input, if available.
          
          #### Duration (*seconds*)
          # *The stay's duration.*
          committee :duration do
            # Use client input, if available.
            
            # Otherwise use 86400 *seconds* (1 night).
            quorum 'default' do
              86400.0
            end
          end
          
          #### Rooms
          # *The number of rooms used.*
          committee :rooms do
            # Use client input, if available.
            
            # Otherwise use 1 *room*.
            quorum 'default' do
              1
            end
          end
        end
      end
    end
  end
end
