# Copyright © 2010 Brighter Planet.
# See LICENSE for details.
# Contact Brighter Planet for dual-license arrangements.

require 'earth/fuel/fuel'
require 'earth/fuel/greenhouse_gas'
require 'earth/hospitality/commercial_building_energy_consumption_survey_response'
require 'earth/locality/country'
require 'earth/locality/electricity_mix'

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
require 'lodging/cbecs'

module BrighterPlanet
  module Lodging
    module ImpactModel
      def self.included(base)
        base.decide :impact, :with => :characteristics do
          # * * *
          
          #### Carbon (*kg CO<sub>2</sub>e*)
          # *The lodging's total anthropogenic greenhouse gas emissions during `timeframe`.*
          committee :carbon do
            # Sum `co2 emission` (*kg*), `ch4 emission` (*kg CO<sub>2</sub>e*) and `n2o emission` (*kg CO<sub>2</sub>e*) to give *kg CO<sub>2</sub>e*.
            quorum 'from co2 emission, ch4 emission, and n2o emission', :needs => [:co2_emission, :ch4_emission, :n2o_emission],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:co2_emission] + characteristics[:ch4_emission] + characteristics[:n2o_emission]
            end
          end
          
          #### CO<sub>2</sub> emission (*kg*)
          # *The lodging's CO<sub>2</sub> emissions during `timeframe`.*
          committee :co2_emission do
            # Multiply each `fuel use` (*MJ*) by its CO<sub>2</sub> emission factor (*kg / MJ*) to give *kg*.
            quorum 'from fuel uses and electricity mix', :needs => [:fuel_uses, :electricity_mix],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                gas = Fuel.find('Pipeline Natural Gas')
                oil = Fuel.find('Distillate Fuel Oil No. 2')
                dh = Fuel.find('District Heat')
                
                (characteristics[:fuel_uses][:natural_gas]   / gas.energy_content * gas.co2_emission_factor) +
                (characteristics[:fuel_uses][:fuel_oil]      / oil.energy_content * oil.co2_emission_factor) +
                (characteristics[:fuel_uses][:district_heat] / dh.energy_content  * dh.co2_emission_factor) +
                (characteristics[:fuel_uses][:electricity].megajoules.to(:kilowatt_hours) * characteristics[:electricity_mix].co2_emission_factor)
            end
          end
          
          #### CH<sub>4</sub> emission (*kg CO<sub>2</sub>e*)
          # *The lodging's CH<sub>4</sub> emissions during `timeframe`.*
          committee :ch4_emission do
            # Multiply each `fuel use` (*MJ*) by its CH<sub>4</sub> emission factor (*kg CO<sub>2</sub>e / MJ*) to give *kg CO<sub>2</sub>e*.
            quorum 'from fuel uses and electricity mix', :needs => [:fuel_uses, :electricity_mix],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                ch4_gwp = GreenhouseGas[:ch4].global_warming_potential
                
                gas_ef = 0.1.grams.to(:kilograms) / 1000.kbtus.to(:megajoules) * ch4_gwp
                oil_ef = 0.6.grams.to(:kilograms) / 1000.kbtus.to(:megajoules) * ch4_gwp
                dh_ef  = (((gas_ef / 0.817) + (oil_ef / 0.846)) / 2.0) / 0.95
                
                (characteristics[:fuel_uses][:natural_gas]   * gas_ef) +
                (characteristics[:fuel_uses][:fuel_oil]      * oil_ef) +
                (characteristics[:fuel_uses][:district_heat] * dh_ef) +
                (characteristics[:fuel_uses][:electricity].megajoules.to(:kilowatt_hours) * characteristics[:electricity_mix].ch4_emission_factor)
            end
          end
          
          #### N<sub>2</sub>O emission (*kg CO<sub>2</sub>e*)
          # *The lodging's N<sub>2</sub>O emissions during `timeframe`.*
          committee :n2o_emission do
            # Multiply each `fuel use` (*MJ*) by its N<sub>2</sub>O emission factor (*kg CO<sub>2</sub>e / MJ*) to give *kg CO<sub>2</sub>e*.
            quorum 'from fuel uses and electricity mix', :needs => [:fuel_uses, :electricity_mix],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                n2o_gwp = GreenhouseGas[:n2o].global_warming_potential
                
                gas_ef = 0.1.grams.to(:kilograms) / 1000.kbtus.to(:megajoules) * n2o_gwp
                oil_ef = 0.6.grams.to(:kilograms) / 1000.kbtus.to(:megajoules) * n2o_gwp
                dh_ef  = (((gas_ef / 0.817) + (oil_ef / 0.846)) / 2.0) / 0.95
                
                (characteristics[:fuel_uses][:natural_gas]   * gas_ef) +
                (characteristics[:fuel_uses][:fuel_oil]      * oil_ef) +
                (characteristics[:fuel_uses][:district_heat] * dh_ef) +
                (characteristics[:fuel_uses][:electricity].megajoules.to(:kilowatt_hours) * characteristics[:electricity_mix].n2o_emission_factor)
            end
          end
          
          #### Energy (*MJ*)
          # *The lodging's total energy use during `timeframe`.*
          committee :energy do
            # Add all the `fuel uses` (*MJ*) to give *MJ*.
            quorum 'from fuel uses', :needs => :fuel_uses,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:fuel_uses].values.sum
            end
          end
          
          #### Fuel uses (*MJ*)
          # *The lodging's use of each fuel during `timeframe`.*
          committee :fuel_uses do
            # Multiply each `adjusted fuel intensity` (*MJ / occupied room-night*) by `room nights` to give *MJ*.
            quorum 'from adjusted fuel intensities and room nights', :needs => [:adjusted_fuel_intensities, :room_nights],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                intensities = characteristics[:adjusted_fuel_intensities]
                {
                  :natural_gas   => intensities[:natural_gas]   * characteristics[:room_nights],
                  :fuel_oil      => intensities[:fuel_oil]      * characteristics[:room_nights],
                  :electricity   => intensities[:electricity]   * characteristics[:room_nights],
                  :district_heat => intensities[:district_heat] * characteristics[:room_nights]
                }
            end
          end
          
          #### Adjusted fuel intensities (*MJ / occupied room-night*)
          # *The lodging's use per occupied room night of a variety of fuels, adjusted by number of pools, mini-fridges, etc.*
          committee :adjusted_fuel_intensities do
            # Adjust `fuel intensities` based on any amenity adjustments:
            quorum 'from fuel intensities and amenity adjustments',
              :needs => :fuel_intensities, :appreciates => [:indoor_pool_adjustment, :outdoor_pool_adjustment, :refrigerator_adjustment, :hot_tub_adjustment],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                intensities = characteristics[:fuel_intensities].dup
                pool_adjustment = 0.0
                
                # Combine any pool energy adjustments.
                # Apply all other adjustments to the appropriate fuel intensity, but do not allow any adjusted fuel intensity to be less than zero.
                characteristics.except(:fuel_intensities).each do |characteristic, adjustment|
                  adjustment.each do |fuel, value|
                    if fuel == :pool_energy
                      pool_adjustment += value
                    elsif (intensities[fuel] += value) < 0.0
                      intensities[fuel] = 0.0
                    end
                  end
                end
                
                # Apply the combined pool energy adjustment to natural gas, fuel oil, and electricity intensities, in that order.
                # If any adjusted intensity reaches zero, apply any remaining adjustment to the next fuel intensity.
                # If adjusted electricity intensity reaches zero, discard any remaining adjustment.
                if pool_adjustment.abs > 0.0
                  if (intensities[:natural_gas] += pool_adjustment) < 0.0
                    if (intensities[:fuel_oil] += intensities[:natural_gas]) < 0.0
                      if (intensities[:electricity] += intensities[:fuel_oil]) < 0.0
                        intensities[:electricity] = 0
                      end
                      intensities[:fuel_oil] = 0
                    end
                    intensities[:natural_gas] = 0
                  end
                end
                intensities
            end
          end
          
          #### Outdoor pools adjustment (*MJ / occupied room-night*)
          # *Adjusts the natural gas intensity based on the number of outdoor pools.*
          committee :outdoor_pool_adjustment do
            # Assume outdoor pool energy intensity of 329,917 *BTU / night* per [Energy Star](http://www.energystar.gov/ia/business/evaluate_performance/swimming_pool_tech_desc.pdf).
            # Calculate the difference between `outdoor pools` and average outdoor pools.
            # Multiply the difference by outdoor pool energy intensity (*MJ / night*) and divide by `property rooms` and `occupancy rate` to give *MJ / occupied room-night*.
            quorum 'from outdoor pools, property rooms, and occupancy rate', :needs => [:outdoor_pools, :property_rooms, :occupancy_rate],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                difference = characteristics[:outdoor_pools] - LodgingProperty.fallback.pools_outdoor
                { :pool_energy => difference * 329_917.btus.to(:megajoules) / characteristics[:property_rooms] / characteristics[:occupancy_rate] }
            end
          end
          
          #### Indoor pools adjustment (*MJ / occupied room-night*)
          # *Adjusts the natural gas intensity based on the number of indoor pools.*
          committee :indoor_pool_adjustment do
            # Assume indoor pool energy intensity of 2,770,942 *BTU / night* per [Energy Star](http://www.energystar.gov/ia/business/evaluate_performance/swimming_pool_tech_desc.pdf).
            # Calculate the difference between `indoor pools` and average indoor pools.
            # Multiply the difference by indoor pool energy intensity (*MJ / night*) and divide by `property rooms` and `occupancy rate` to give *MJ / occupied room-night*.
            quorum 'from indoor pools, property rooms, and occupancy rate', :needs => [:indoor_pools, :property_rooms, :occupancy_rate],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                difference = characteristics[:indoor_pools] - LodgingProperty.fallback.pools_indoor
                { :pool_energy => difference * 2_770_942.btus.to(:megajoules) / characteristics[:property_rooms] / characteristics[:occupancy_rate] }
            end
          end
          
          #### Hot tub adjustment (*MJ / occupied room-night*)
          # *Adjusts the electricity intensity based on the number of hot tubs.*
          committee :hot_tub_adjustment do
            # Calculate the difference between `hot tubs` and average hot tubs.
            # Assume hot tub electricity intensity of 6.3 *kWh / night* per [LBL residential energy data sourcebook, p128](http://enduse.lbl.gov/info/LBNL-40297.pdf).
            # Multiply the difference by the hot tub electricity intensity (*kWh / night*) and divide by `property rooms` and `occupancy rate` to give *kWh / occupied room-night*.
            quorum 'from hot tubs, property rooms, and occupancy rate', :needs => [:hot_tubs, :property_rooms, :occupancy_rate],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                difference = characteristics[:hot_tubs] - LodgingProperty.fallback.hot_tubs
                { :electricity => difference * 6.3.kilowatt_hours.to(:megajoules) / characteristics[:property_rooms] / characteristics[:occupancy_rate] }
            end
          end
          
          #### Refrigerator adjustment (*MJ / occupied room-night*)
          # *Adjusts the electricity intensity based on refrigerator coverage.*
          committee :refrigerator_adjustment do
            # Calculate the difference between `refrigerator coverage` (*refrigerators / room*) and average refrigerator coverage (*refrigerators / room*).
            # Assume an auto-defrost compact fridge electricity intensity of 1.18 *kWh / refrigerator night* per [Energy Star](http://www.energystar.gov/ia/business/bulk_purchasing/bpsavings_calc/Bulk_Purchasing_CompactRefrig_Sav_Calc.xls).
            # Multiply the difference (*refrigerators / room*) by the refrigerator electricity intensity (*kWh / refrigerator night*) and divide by `occupancy rate` to give *kWh / occupied room-night*.
            quorum 'from refrigerator coverage and occupancy rate', :needs => [:refrigerator_coverage, :occupancy_rate],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                difference = characteristics[:refrigerator_coverage] - LodgingProperty.fallback.fridge_coverage
                { :electricity => (difference * 1.18.kilowatt_hours.to(:megajoules) / characteristics[:occupancy_rate]) }
            end
          end
          
          #### Fuel intensities (*MJ / occupied room-night*)
          # *The lodging's use per occupied room night of a variety of fuels.*
          committee :fuel_intensities do
            # If we know `heating degree days` and `cooling degree days`, calculate fuel intensities from [CBECS 2003](http://data.brighterplanet.com/commercial_building_energy_consumption_survey_responses) data using fuzzy inference and adjust the inferred values based on `occupancy rate`.
            quorum 'from degree days, occupancy rate, and user inputs', :needs => [:heating_degree_days, :cooling_degree_days, :occupancy_rate], :appreciates => [:property_rooms, :floors, :construction_year, :ac_coverage],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                inputs = characteristics.except(:occupancy_rate).to_hash.inject({}) do |memo, (characteristic, value)|
                  case characteristic
                  when :property_rooms
                    memo[:lodging_rooms] = value
                  when :ac_coverage
                    memo[:percent_cooled] = value
                  else
                    memo[characteristic] = value
                  end
                  memo
                end
                
                kernel = CommercialBuildingEnergyConsumptionSurveyResponse.new(inputs)
                n, f, e, d = kernel.fuzzy_infer(:natural_gas_per_room_night, :fuel_oil_per_room_night, :electricity_per_room_night, :district_heat_per_room_night)
                {
                  :natural_gas   => n / characteristics[:occupancy_rate],
                  :fuel_oil      => f / characteristics[:occupancy_rate],
                  :electricity   => e / characteristics[:occupancy_rate],
                  :district_heat => d / characteristics[:occupancy_rate]
                }
            end
            
            # Otherwise use global averages.
            quorum 'default',
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do
                intensities = {
                  :natural_gas =>   Country.fallback.lodging_natural_gas_intensity   / Country.fallback.lodging_occupancy_rate,
                  :fuel_oil =>      Country.fallback.lodging_fuel_oil_intensity      / Country.fallback.lodging_occupancy_rate,
                  :electricity =>   Country.fallback.lodging_electricity_intensity   / Country.fallback.lodging_occupancy_rate,
                  :district_heat => Country.fallback.lodging_district_heat_intensity / Country.fallback.lodging_occupancy_rate
                }
            end
          end
          
          #### Occupancy rate
          # *The percent of the proprety's rooms that are occupied on an average night.*
          committee :occupancy_rate do
            # Look up the `country` average lodging occupancy rate.
            quorum 'from country', :needs => :country,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:country].lodging_occupancy_rate
            end
            
            # Otherwise use a global average.
            quorum 'default', :complies => [:ghg_protocol_scope_3, :iso, :tcr] do
              Country.fallback.lodging_occupancy_rate
            end
          end
          
          #### Outdoor pools
          # *The number of outdoor pools.*
          committee :outdoor_pools do
            # Use client input, if available.
            
            # Otherwise look up the `property` number of outdoor pools, but set a ceiling of 5 outdoor pools.
            quorum 'from property', :needs => :property,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                unless characteristics[:property].pools_outdoor.nil?
                  [characteristics[:property].pools_outdoor.to_f, 5].min
                end
            end
          end
          
          #### Indoor pools
          # *The number of indoor pools.*
          committee :indoor_pools do
            # Use client input, if available.
            
            # Otherwise look up the `property` number of indoor pools, but set a ceiling of 5 indoor pools.
            quorum 'from property', :needs => :property,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                unless characteristics[:property].pools_indoor.nil?
                  [characteristics[:property].pools_indoor.to_f, 5].min
                end
            end
          end
          
          #### Hot tubs
          # *The number of hot tubs.*
          committee :hot_tubs do
            # Use client input, if available.
            
            # Otherwise look up the `property` number of hot tubs.
            quorum 'from property', :needs => :property,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:property].hot_tubs
            end
          end
          
          #### Refrigerator coverage
          # *The percentage of property rooms that have refrigerators.*
          committee :refrigerator_coverage do
            # Use client input, if available.
            # Otherwise take whichever is greater of the `property` refrigerator coverage and mini bar coverage.
            quorum 'from property', :needs => :property,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                if characteristics[:property].mini_bar_coverage || characteristics[:property].fridge_coverage
                  [characteristics[:property].mini_bar_coverage.to_f, characteristics[:property].fridge_coverage.to_f].max
                end
            end
          end
          
          #### A/C coverage
          # *The percentage of property rooms that are air conditioned.*
          committee :ac_coverage do
            # Use client input, if available.
            
            # Otherwise look up the `property` A/C coverage.
            quorum 'from property', :needs => :property,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:property].ac_coverage
            end
          end
          
          #### Construction year
          # *The year the property was built.*
          committee :construction_year do
            # Use client input, if available.
            
            # Otherwise look up the year the `property` was built.
            quorum 'from property', :needs => :property,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:property].construction_year
            end
          end
          
          #### Floors
          # *The number of floors.*
          committee :floors do
            # Use client input, if available.
            
            # Otherwise look up the `property` number of floors.
            quorum 'from property', :needs => :property,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:property].floors
            end
          end
          
          #### Property rooms
          # *The number of guest rooms in the property.*
          committee :property_rooms do
            # Use client input, if available.
            
            # Otherwise look up the `property` number of rooms.
            quorum 'from property', :needs => :property,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:property].lodging_rooms
            end
          end
          
          #### Property
          # *The property where the stay occurred.*
          #
          # Use client input, if available
          
          #### Electricity mix
          # *The lodging's locality-specific [electricity mix](http://data.brighterplanet.com/electricity_mixes).*
          committee :electricity_mix do
            # Use the `egrid subregion` electricity mix.
            quorum 'from egrid subregion', :needs => :egrid_subregion,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:egrid_subregion].electricity_mix
            end
            
            # Otherwise use the `state` electricity mix.
            quorum 'from state', :needs => :state,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:state].electricity_mix
            end
            
            # Otherwise use the `country` electricity mix.
            quorum 'from country', :needs => :country,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:country].electricity_mix
            end
            
            # Otherwise use a global average electricity mix.
            quorum 'default',
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do
                ElectricityMix.fallback
            end
          end
          
          #### Heating degree days
          # *The average number of annual heating degree days (base 18°C) at the lodging's location.*
          committee :heating_degree_days do
            # Use client input, if available
            
            # Otherwise look up the `climate division` heating degree days.
            quorum 'from climate division', :needs => :climate_division,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:climate_division].heating_degree_days
            end
            
            # Otherwise look up the `country` heating degree days.
            quorum 'from country', :needs => :country,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:country].heating_degree_days
            end
          end
          
          #### Cooling degree days
          # *The average number of annual cooling degree days (base 18°C) at the lodging's location.*
          committee :cooling_degree_days do
            # Use client input, if available
            
            # Otherwise look up the `climate division` cooling degree days.
            quorum 'from climate division', :needs => :climate_division,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:climate_division].cooling_degree_days
            end
            
            # Otherwise look up the `country` cooling degree days.
            quorum 'from country', :needs => :country,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:country].cooling_degree_days
            end
          end
          
          #### Country
          # *The [country](http://data.brighterplanet.com/countries).*
          committee :country do
            # Use client input, if available.
            
            # Otherwise if state is defined then the country is the United States.
            quorum 'from state', :needs => :state,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                Country.united_states
            end
          end
          
          #### eGRID subregion
          # *The [eGRID subregion](http://data.brighterplanet.com/egrid_subregions).*
          committee :egrid_subregion do
            # Look up the `zip code` eGRID subregion.
            quorum 'from zip code', :needs => :zip_code,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:zip_code].egrid_subregion
            end
          end
          
          #### State
          # *The [US state](http://data.brighterplanet.com/states).*
          committee :state do
            # Use client input, if available.
            
            # Otherwise look up the `zip code` state.
            quorum 'from zip code', :needs => :zip_code,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:zip_code].state
            end
          end
          
          #### City
          # *The city.*
          committee :city do
            # Use client input, if available.
            
            # Otherwise look up the `zip code` description.
            quorum 'from zip code', :needs => :zip_code,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:zip_code].description
            end
          end
          
          #### Climate division
          # *The [US climate division](http://data.brighterplanet.com/climate_divisions).*
          committee :climate_division do
            # Look up the `zip code` climate division.
            quorum 'from zip code', :needs => :zip_code,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:zip_code].climate_division
            end
          end
          
          #### Zip code
          # *The [US zip code](http://data.brighterplanet.com/zip_codes).*
          #
          # Use client input, if available.
          
          #### Room nights (*room-nights*)
          # *The stay's room-nights that occurred during `timeframe`.*
          committee :room_nights do
            # If `date` falls within `timeframe`, divide `duration` (*seconds*) by 86,400 (*seconds / night*) and multiply by `rooms` to give *room-nights*.
            # Otherwise `room nights` is zero.
            quorum 'from rooms, duration, date, and timeframe', :needs => [:rooms, :duration, :date],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics, timeframe|
                date = characteristics[:date].is_a?(Date) ? characteristics[:date] : Date.parse(characteristics[:date].to_s)
                timeframe.include?(date) ? characteristics[:duration] / 86400.0 * characteristics[:rooms] : 0
            end
          end
          
          #### Duration (*seconds*)
          # *The stay's duration. Use 24 hours for each night stayed. For example a two night stay would have a duration of 172800.*
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
          
          #### Date (*date*)
          # *The day the stay occurred.*
          committee :date do
            # Use client input, if available.
            
            # Otherwise use the first day of `timeframe`.
            quorum 'from timeframe',
              :complies => [:ghg_protocol_scope_3, :iso] do |characteristics, timeframe|
                timeframe.from
            end
          end
        end
      end
    end
  end
end
