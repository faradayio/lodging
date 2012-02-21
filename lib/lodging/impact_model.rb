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
            # Multiply by `emission factor` (*kg CO<sub>2</sub>e / room-night*) to give *kg CO<sub>2</sub>e.
            quorum 'from natural gas use, fuel oil use, electricity use, district heat use, and electricity emission factor', :needs => [:natural_gas_use, :fuel_oil_use, :electricity_use, :district_heat_use, :electricity_emission_factor],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:natural_gas_use] * Fuel.find_by_name('Pipeline Natural Gas').co2_emission_factor +
                characteristics[:fuel_oil_use] * Fuel.find_by_name('Distillate Fuel Oil No. 2').co2_emission_factor +
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
          # The lodging's natural gas use during `timeframe`.
          committee :natural_gas_use do
            # Multiply `room nights` (*room-nights*) by `natural gas intensity` (*m<sup>3</sup> / room-night*) to give *m<sup>3</sup>*.
            quorum 'from adjusted fuel intensities and room nights', :needs => [:adjusted_fuel_intensities, :room_nights],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:room_nights] * characteristics[:adjusted_fuel_intensities][:natural_gas]
            end
          end
          
          #### Fuel oil use (*l*)
          # The lodging's fuel oil use during `timeframe`.
          committee :fuel_oil_use do
            # Multiply `room nights` (*room-nights*) by `fuel oil intensity` (*l / room-night*) to give *l*.
            quorum 'from adjusted fuel intensities and room nights', :needs => [:adjusted_fuel_intensities, :room_nights],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:room_nights] * characteristics[:adjusted_fuel_intensities][:fuel_oil]
            end
          end
          
          #### Electricity use (*kWh*)
          # The lodging's electricity use during `timeframe`.
          committee :electricity_use do
            # Multiply `room nights` (*room-nights*) by `electricity intensity` (*kWh / room-night*) to give *kWh*.
            quorum 'from adjusted fuel intensities and room nights', :needs => [:adjusted_fuel_intensities, :room_nights],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:room_nights] * characteristics[:adjusted_fuel_intensities][:electricity]
            end
          end
          
          #### District heat use (*MJ*)
          # The lodging's district heat use during `timeframe`.
          committee :district_heat_use do
            # Multiply `room nights` (*room-nights*) by `district heat intensity` (*MJ / room-night*) to give *MJ*.
            quorum 'from adjusted fuel intensities and room nights', :needs => [:adjusted_fuel_intensities, :room_nights],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:room_nights] * characteristics[:adjusted_fuel_intensities][:district_heat]
            end
          end
          
          #### Adjusted fuel intensities (*various*)
          # *The lodging's use per occupied room night of a variety of fuels, 
          # adjusted by number of pools, mini-fridges, etc.*
          #
          # - Natural gas intensity: *m<sup>3</sup> / room-night*
          # - Fuel oil intensity: *l / room-night*
          # - Electricity intensity: *kWh / room-night*
          # - District heat intensity: *MJ / room-night*
          committee :adjusted_fuel_intensities do
            quorum 'from fuel intensities and amenity adjustments',
              :needs => [:fuel_intensities, :indoor_pool_adjustment, :outdoor_pool_adjustment, :fridge_adjustment, :hot_tub_adjustment] do |characteristics|
              intensities = characteristics[:fuel_intensities]
              
              [:indoor_pool_adjustment, :outdoor_pool_adjustment, :fridge_adjustment, :hot_tub_adjustment].each do |adjustment|
                characteristics[adjustment].each do |fuel, intensity|
                  puts "adjusting #{fuel} (#{intensities[fuel]}) by #{intensity}"
                  intensities[fuel] = intensities[fuel] + intensity
                end
              end
              intensities
            end
          end
          
          #### Indoor pool adjustment
          #
          committee :indoor_pool_adjustment do
            # If `country` is the US, calculate fuel adjustment according to typical
            # pool energy consumption of 1,011,394,000 BTU/year
            # http://www.energystar.gov/ia/business/evaluate_performance/swimming_pool_tech_desc.pdf
            # Recreational pool size assumed
            quorum 'from property_indoor_pool_count', :needs => [:fuel_intensities, :property_indoor_pool_count] do |characteristics|
              
              indoor_pool_fallback = LodgingProperty.fallback.pools_indoor
              if characteristics[:property_indoor_pool_count] > 0
                energy = (characteristics[:property_indoor_pool_count] - indoor_pool_fallback) * 2_770_942.47
              else
                energy = -1 * indoor_pool_fallback * 2_770_942.47
              end
              if characteristics[:fuel_intensities][:fuel_oil] > 0
                {
                  :fuel_oil => energy.btus.to(:megajoules) / Fuel.find_by_name('Residual Fuel Oil No. 5').energy_content
                }
              else
                {
                  :natural_gas => energy.btus.to(:megajoules) / Fuel.find_by_name('Pipeline Natural Gas').energy_content
                }
              end
            end
            quorum 'default' do
              {}
            end
          end
          
          #### Outdoor pool adjustment
          #
          committee :outdoor_pool_adjustment do
            # If `country` is the US, calculate fuel adjustment according to typical hot 
            # pool energy consumption of 120,420,000 BTU/year
            # http://www.energystar.gov/ia/business/evaluate_performance/swimming_pool_tech_desc.pdf
            # Recreational pool size assumed
            quorum 'from property_outdoor_pool_count', :needs => [:fuel_intensities, :property_outdoor_pool_count] do |characteristics|
              indoor_pool_fallback = LodgingProperty.fallback.pools_indoor
              if characteristics[:property_outdoor_pool_count] > 0
                energy = (characteristics[:property_outdoor_pool_count] - indoor_pool_fallback) * 329_917.808
              else
                energy = -1 * indoor_pool_fallback * 329_917.808
              end
              if characteristics[:fuel_intensities][:fuel_oil] > 0
                {
                  :fuel_oil => energy.btus.to(:megajoules) / Fuel.find_by_name('Residual Fuel Oil No. 5').energy_content
                }
              else
                {
                  :natural_gas => energy.btus.to(:megajoules) / Fuel.find_by_name('Pipeline Natural Gas').energy_content
                }
              end
            end
            quorum 'default' do
              {}
            end
          end
          
          #### Hot tub adjustment
          #
          committee :hot_tub_adjustment do
            # If `country` is the US, calculate fuel adjustment according to typical hot 
            # tub electricity consumption of 2300kWh/yr
            # http://enduse.lbl.gov/info/LBNL-40297.pdf (page 128)
            quorum 'from property_hot_tub_count', :needs => :property_hot_tub_count do |characteristics|
              hot_tub_fallback = LodgingProperty.fallback.hot_tubs
              if characteristics[:property_hot_tub_count] > 0
                {
                  :electricity => ((characteristics[:property_hot_tub_count] - hot_tub_fallback) * 6.30137)
                }
              else
                {
                  :electricity => (-1 * hot_tub_fallback * 6.30137)
                }
              end
            end
            quorum 'default' do
              {}
            end
          end
          
          #### Fridge adjustment
          #
          committee :fridge_adjustment do
            # If `country` is the US, calculate fuel adjustment according to typical fridge
            # electricity consumption of 1.8kWh/day
            # http://www.energystar.gov/ia/business/bulk_purchasing/bpsavings_calc/Bulk_Purchasing_CompactRefrig_Sav_Calc.xls
            # auto-defrost compact fridge assumed
            quorum 'from property_fridge_coverage', :needs => :property_fridge_coverage do |characteristics|
              fridge_fallback = [LodgingProperty.fallback.fridge_coverage,
                                 LodgingProperty.fallback.mini_bar_coverage].max
              if characteristics[:property_fridge_coverage] > 0
                {
                  :electricity => ((characteristics[:property_fridge_coverage] - fridge_fallback) * 1.8)
                }
              else
                {
                  :electricity => (-1 * fridge_fallback * 1.8)
                }
              end
            end
            quorum 'default' do
              {}
            end
          end
          
          #### Fuel intensities (*various*)
          # *The lodging's use per occupied room night of a variety of fuels.*
          #
          # - Natural gas intensity: *m<sup>3</sup> / room-night*
          # - Fuel oil intensity: *l / room-night*
          # - Electricity intensity: *kWh / room-night*
          # - District heat intensity: *MJ / room-night*
          committee :fuel_intensities do
            # If we know `heating degree days` and `cooling degree days`, calculate fuel intensities from CBECS 2003 data using fuzzy inference.
            quorum 'from degree days, occupancy rate, and user inputs', :needs => [:heating_degree_days, :cooling_degree_days, :occupancy_rate], :appreciates => [:property_rooms, :property_floors, :property_construction_year, :property_ac_coverage],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                occupancy_rate = 0 # Declare occupancy rate so it will be available outside of the inject
                inputs = characteristics.to_hash.inject({}) do |memo, (characteristic, value)|
                  case characteristic
                  when :occupancy_rate
                    occupancy_rate = value
                  when :property_rooms
                    memo[:lodging_rooms] = value
                  when :property_floors
                    memo[:floors] = value
                  when :property_construction_year
                    memo[:construction_year] = value
                  when :property_ac_coverage
                    memo[:percent_cooled] = value
                  else
                    memo[characteristic] = value
                  end
                  memo
                end
                
                kernel = CommercialBuildingEnergyConsumptionSurveyResponse.new(inputs)
                {
                  :natural_gas   => kernel.fuzzy_infer(:natural_gas_per_room_night) / occupancy_rate,
                  :fuel_oil      => kernel.fuzzy_infer(:fuel_oil_per_room_night) / occupancy_rate,
                  :electricity   => kernel.fuzzy_infer(:electricity_per_room_night) / occupancy_rate,
                  :district_heat => kernel.fuzzy_infer(:district_heat_per_room_night) / occupancy_rate
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
            quorum 'default' do
              Country.fallback.lodging_occupancy_rate
            end
          end
          
          #### Property indoor pool count
          # *The number of the property's indoor pools
          committee :property_indoor_pool_count do
            quorum 'from property', :needs => :property do |characteristics|
              unless characteristics[:property].pools_indoor.nil?
                [characteristics[:property].pools_indoor.to_f, 5].min
              end
            end
          end
          
          #### Property outdoor pool count
          # *The number of the property's outdoor pools
          committee :property_outdoor_pool_count do
            quorum 'from property', :needs => :property do |characteristics|
              unless characteristics[:property].pools_outdoor.nil?
                [characteristics[:property].pools_outdoor.to_f, 5].min
              end
            end
          end
          
          #### Property hot tub count
          # *The number of the property's hot tubs
          committee :property_hot_tub_count do
            quorum 'from property', :needs => :property do |characteristics|
              characteristics[:property].hot_tubs
            end
          end
          
          #### Property fridge count
          # *The percentage of the property's rooms that have fridges
          committee :property_fridge_coverage do
            quorum 'from property', :needs => :property do |characteristics|
              if characteristics[:property].mini_bar_coverage ||
                characteristics[:property].fridge_coverage
                [characteristics[:property].mini_bar_coverage.to_f +
                 characteristics[:property].fridge_coverage.to_f].max
              end
            end
          end
          
          #### Property A/C coverage
          # *The percent of the property that is air conditioned.*
          committee :property_ac_coverage do
            # Use client input, if available.
            
            # Otherwise look up the `property` cooled portion.
            quorum 'from property', :needs => :property,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:property].ac_coverage
            end
          end
          
          #### Property construction year
          # *The year the property was built.*
          committee :property_construction_year do
            # Use client input, if available.
            
            # Otherwise look up the year the `property` was built.
            quorum 'from property', :needs => :property,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:property].construction_year
            end
          end
          
          #### Property floors
          # *The number of floors in the property.*
          committee :property_floors do
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
          committee :property do
            # Use client input, if available.
            
            # Otherwise use a custom matching algorithm to look up a property based on user inputs.
            quorum "from custom matching algorithm", :needs => :property_name, :appreciates => [:zip_code, :city, :state, :country],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                LodgingProperty.better_match characteristics
            end
          end
          
          #### Property name
          # *The name of the property where the stay occurred.*
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
          # *The property's [eGRID subregion](http://data.brighterplanet.com/egrid_subregions).*
          committee :egrid_subregion do
            # Look up the `zip code` eGRID subregion.
            quorum 'from zip code', :needs => :zip_code,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:zip_code].egrid_subregion
            end
          end
          
          #### Country
          # *The property's [country](http://data.brighterplanet.com/countries).*
          committee :country do
            # Use client input, if available.
            
            # Otherwise if state is defined then the country is the United States.
            quorum 'from state', :needs => :state,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                Country.united_states
            end
          end
          
          #### State
          # *The property's [US state](http://data.brighterplanet.com/states).*
          committee :state do
            # Use client input, if available.
            
            # Otherwise look up the `zip code` state.
            quorum 'from zip code', :needs => :zip_code,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:zip_code].state
            end
          end
          
          #### City
          # *The property's city.*
          committee :city do
            # Use client input, if available.
            
            # Otherwise look up the `zip code` description.
            quorum 'from zip code', :needs => :zip_code,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:zip_code].description
            end
          end
          
          #### Climate division
          # *The property's [US climate division](http://data.brighterplanet.com/climate_divisions).*
          committee :climate_division do
            # Look up the `zip code` climate division.
            quorum 'from zip code', :needs => :zip_code,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:zip_code].climate_division
            end
          end
          
          #### Zip code
          # *The property's [US zip code](http://data.brighterplanet.com/zip_codes).*
          #
          # Use client input, if available.
          
          #### Room nights (*room-nights*)
          # The stay's room-nights that occurred during `timeframe`.
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
