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
            # Multiply `natural gas use` (*m<sup>3</sup>*) by natural gas' emission factor (*kg CO<sub>2</sub> / m<sup>3</sup>*) to give *kg CO<sub>2</sub>.*
            # Multiply `fuel oil use` (*l*) by fuel oil's emission factor (*kg CO<sub>2</sub> / l*) to give *kg CO<sub>2</sub>.*
            # Multiply `electricity use` (*kWh*) by `electricity emission factor` (*kg CO<sub>2</sub> / kWh*) to give *kg CO<sub>2</sub>.*
            # Multiply `district heat use` (*MJ*) by district heat's emission factor` (*kg CO<sub>2</sub> / MJ*) to give *kg CO<sub>2</sub>.*
            # Sum to give *kg CO<sub>2</sub>e.*
            quorum 'from natural gas use, fuel oil use, electricity use, district heat use, and electricity emission factor', :needs => [:natural_gas_use, :fuel_oil_use, :electricity_use, :district_heat_use, :electricity_emission_factor],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:natural_gas_use] * Fuel.find_by_name('Pipeline Natural Gas').co2_emission_factor +
                characteristics[:fuel_oil_use] * Fuel.find_by_name('Residual Fuel Oil No. 6').co2_emission_factor +
                characteristics[:electricity_use] * characteristics[:electricity_emission_factor] +
                characteristics[:district_heat_use] * Fuel.find_by_name('District Heat').co2_emission_factor
            end
          end
          
          #### Electricity emission factor (*kg CO<sub>2</sub>e / kWh*)
          # *A greenhouse gas emission factor for electricity used by the lodging.*
          committee :electricity_emission_factor do
            # Multiply the `eGRID subregion` electricity emission factors by 1 minus the the subregion's eGRID region loss factor (to account for transmission and distribution losses) to give *kg CO<sub>2</sub>e / kWh*.
            quorum 'from eGRID subregion', :needs => :egrid_subregion,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:egrid_subregion].electricity_emission_factor / (1 - characteristics[:egrid_subregion].egrid_region.loss_factor)
            end
            
            # Otherwise look up the `country` electricity emission factor (*kg CO<sub>2</sub>e / kWh*).
            quorum 'from country', :needs => :country,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:country].electricity_emission_factor
            end
            
            # Otherwise use a global average electricity emission factor (*kg CO<sub>2</sub>e / kWh*).
            quorum 'default',
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do
                Country.fallback.electricity_emission_factor
            end
          end
          
          #### Natural gas use (*m<sup>3</sup>*)
          # *The lodging's natural gas use during `timeframe`.*
          committee :natural_gas_use do
            # Multiply `room nights` (*room-nights*) by `natural gas intensity` (*m<sup>3</sup> / occupied room-night*) to give *m<sup>3</sup>*.
            quorum 'from adjusted fuel intensities and room nights', :needs => [:adjusted_fuel_intensities, :room_nights],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:room_nights] * characteristics[:adjusted_fuel_intensities][:natural_gas]
            end
          end
          
          #### Fuel oil use (*l*)
          # *The lodging's fuel oil use during `timeframe`.*
          committee :fuel_oil_use do
            # Multiply `room nights` (*room-nights*) by `fuel oil intensity` (*l / occupied room-night*) to give *l*.
            quorum 'from adjusted fuel intensities and room nights', :needs => [:adjusted_fuel_intensities, :room_nights],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:room_nights] * characteristics[:adjusted_fuel_intensities][:fuel_oil]
            end
          end
          
          #### Electricity use (*kWh*)
          # *The lodging's electricity use during `timeframe`.*
          committee :electricity_use do
            # Multiply `room nights` (*room-nights*) by `electricity intensity` (*kWh / occupied room-night*) to give *kWh*.
            quorum 'from adjusted fuel intensities and room nights', :needs => [:adjusted_fuel_intensities, :room_nights],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:room_nights] * characteristics[:adjusted_fuel_intensities][:electricity]
            end
          end
          
          #### District heat use (*MJ*)
          # *The lodging's district heat use during `timeframe`.*
          committee :district_heat_use do
            # Multiply `room nights` (*room-nights*) by `district heat intensity` (*MJ / occupied room-night*) to give *MJ*.
            quorum 'from adjusted fuel intensities and room nights', :needs => [:adjusted_fuel_intensities, :room_nights],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:room_nights] * characteristics[:adjusted_fuel_intensities][:district_heat]
            end
          end
          
          #### Adjusted fuel intensities (*various*)
          # *The lodging's use per occupied room night of a variety of fuels, adjusted by number of pools, mini-fridges, etc.*
          #
          # - Natural gas intensity: *m<sup>3</sup> / occupied room-night*
          # - Fuel oil intensity: *l / occupied room-night*
          # - Electricity intensity: *kWh / occupied room-night*
          # - District heat intensity: *MJ / occupied room-night*
          committee :adjusted_fuel_intensities do
            # Adjust `fuel intensities` based on any amenity adjustments:
            quorum 'from fuel intensities and amenity adjustments',
              :needs => :fuel_intensities, :appreciates => [:indoor_pool_adjustment, :outdoor_pool_adjustment, :refrigerator_adjustment, :hot_tub_adjustment],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                gas = Fuel.find_by_name('Pipeline Natural Gas')
                oil = Fuel.find_by_name('Residual Fuel Oil No. 6')
                
                # Duplicate the current intensities so we don't overwrite them.
                intensities = characteristics[:fuel_intensities].dup
                
                # Cycle through each adjustment...
                characteristics.each do |characteristic, value|
                  unless characteristic == :fuel_intensities
                    value.each do |fuel, adjustment|
                      if fuel == :pool_energy
                        # If the adjustment relates to pool energy, convert natural gas and fuel oil inensities from physical units to energy units.
                        gas_energy = intensities[:natural_gas] * gas.energy_content
                        oil_energy = intensities[:fuel_oil]    * oil.energy_content
                        
                        # Apply the adjustment to natural gas intensity.
                        # If adjusted natural gas intensity reaches zero, apply any remaining adjustment to fuel oil intensity.
                        # If adjusted fuel oil intensity also reaches zero, discard any remaining adjustment.
                        if (gas_energy += adjustment) < 0.0
                          if (oil_energy += gas_energy) < 0.0
                            oil_energy = 0.0
                          end
                          gas_energy = 0
                        end
                        
                        # Convert adjusted natural gas and fuel oil intensities from energy units back to physical units.
                        intensities[:natural_gas] = gas_energy / gas.energy_content
                        intensities[:fuel_oil]    = oil_energy / oil.energy_content
                      # Otherwise apply the adjustment to the appropriate fuel intensity. If adjusted fuel intensity reaches zero, discard any remaining adjustment.
                      elsif (intensities[fuel] += adjustment) < 0.0
                        intensities[fuel] = 0.0
                      end
                    end
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
          
          #### Hot tub adjustment (*kWh / occupied room-night*)
          # *Adjusts the electricity intensity based on the number of hot tubs.*
          committee :hot_tub_adjustment do
            # Calculate the difference between `hot tubs` and average hot tubs.
            # Assume hot tub electricity intensity of 6.3 *kWh / night* per [LBL residential energy data sourcebook, p128](http://enduse.lbl.gov/info/LBNL-40297.pdf).
            # Multiply the difference by the hot tub electricity intensity (*kWh / night*) and divide by `property rooms` and `occupancy rate` to give *kWh / occupied room-night*.
            quorum 'from hot tubs, property rooms, and occupancy rate', :needs => [:hot_tubs, :property_rooms, :occupancy_rate],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                difference = characteristics[:hot_tubs] - LodgingProperty.fallback.hot_tubs
                { :electricity => difference * 6.3 / characteristics[:property_rooms] / characteristics[:occupancy_rate] }
            end
          end
          
          #### Refrigerator adjustment (*kWh / occupied room-night*)
          # *Adjusts the electricity intensity based on refrigerator coverage.*
          committee :refrigerator_adjustment do
            # Calculate the difference between `refrigerator coverage` (*refrigerators / room*) and average refrigerator coverage (*refrigerators / room*).
            # Assume an auto-defrost compact fridge electricity intensity of 1.18 *kWh / refrigerator night* per [Energy Star](http://www.energystar.gov/ia/business/bulk_purchasing/bpsavings_calc/Bulk_Purchasing_CompactRefrig_Sav_Calc.xls).
            # Multiply the difference (*refrigerators / room*) by the refrigerator electricity intensity (*kWh / refrigerator night*) and divide by `occupancy rate` to give *kWh / occupied room-night*.
            quorum 'from refrigerator coverage and occupancy rate', :needs => [:refrigerator_coverage, :occupancy_rate],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                difference = characteristics[:refrigerator_coverage] - LodgingProperty.fallback.fridge_coverage
                { :electricity => (difference * 1.18 / characteristics[:occupancy_rate]) }
            end
          end
          
          #### Fuel intensities (*various*)
          # *The lodging's use per occupied room night of a variety of fuels.*
          #
          # - Natural gas intensity: *m<sup>3</sup> / occupied room-night*
          # - Fuel oil intensity: *l / occupied room-night*
          # - Electricity intensity: *kWh / occupied room-night*
          # - District heat intensity: *MJ / occupied room-night*
          committee :fuel_intensities do
            # If we know `heating degree days` and `cooling degree days`, calculate fuel intensities from [CBECS 2003](http://data.brighterplanet.com/commercial_building_energy_consumption_survey_responses) data using fuzzy inference and adjust the inferred values based on `occupancy rate`.
            quorum 'from degree days, occupancy rate, and user inputs', :needs => [:heating_degree_days, :cooling_degree_days, :occupancy_rate], :appreciates => [:property_rooms, :floors, :construction_year, :ac_coverage],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                inputs = characteristics.to_hash.inject({}) do |memo, (characteristic, value)|
                  case characteristic
                  when :property_rooms
                    memo[:lodging_rooms] = value
                  when :ac_coverage
                    memo[:percent_cooled] = value
                  when :occupancy_rate
                    # Don't include `occupancy rate` in inputs to fuzzy inference
                  else
                    memo[characteristic] = value
                  end
                  memo
                end
                
                kernel = CommercialBuildingEnergyConsumptionSurveyResponse.new(inputs)
                {
                  :natural_gas   => kernel.fuzzy_infer(:natural_gas_per_room_night) / characteristics[:occupancy_rate],
                  :fuel_oil      => kernel.fuzzy_infer(:fuel_oil_per_room_night) / characteristics[:occupancy_rate],
                  :electricity   => kernel.fuzzy_infer(:electricity_per_room_night) / characteristics[:occupancy_rate],
                  :district_heat => kernel.fuzzy_infer(:district_heat_per_room_night) / characteristics[:occupancy_rate]
                }
            end
            
            # Otherwise use global averages.
            quorum 'default',
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                intensities = {
                  :natural_gas   => Country.fallback.lodging_natural_gas_intensity,
                  :fuel_oil      => Country.fallback.lodging_fuel_oil_intensity,
                  :electricity   => Country.fallback.lodging_electricity_intensity,
                  :district_heat => Country.fallback.lodging_district_heat_intensity,
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
          
          #### eGRID subregion
          # *The [eGRID subregion](http://data.brighterplanet.com/egrid_subregions).*
          committee :egrid_subregion do
            # Look up the `zip code` eGRID subregion.
            quorum 'from zip code', :needs => :zip_code,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:zip_code].egrid_subregion
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
